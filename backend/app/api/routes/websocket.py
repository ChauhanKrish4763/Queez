from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from app.services.connection_manager import manager
from app.services.session_manager import SessionManager
from app.services.game_controller import GameController
from app.services.leaderboard_manager import LeaderboardManager
import json
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

session_manager = SessionManager()
game_controller = GameController()
leaderboard_manager = LeaderboardManager()

@router.websocket("/ws/{session_code}")
async def websocket_endpoint(websocket: WebSocket, session_code: str, user_id: str = Query(...)):
    # Initial connection
    # We require user_id query param to track the connection even before "join"
    # But we won't add them to the session participants list until they send "join"
    
    await manager.connect(websocket, session_code, user_id)
    
    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            msg_type = message.get("type")
            payload = message.get("payload", {})
            
            if msg_type == "join":
                await handle_join(websocket, session_code, user_id, payload)
            elif msg_type == "submit_answer":
                await handle_submit_answer(session_code, user_id, payload)
            elif msg_type == "start_quiz":
                await handle_start_quiz(session_code, user_id)
            elif msg_type == "end_quiz":
                await handle_end_quiz(session_code, user_id)
            elif msg_type == "ping":
                await websocket.send_json({"type": "pong"})
                
    except WebSocketDisconnect:
        manager.disconnect(websocket, session_code, user_id)
        await handle_disconnect(session_code, user_id)
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        manager.disconnect(websocket, session_code, user_id)

async def handle_join(websocket: WebSocket, session_code: str, user_id: str, payload: dict):
    username = payload.get("username", "Anonymous")
    
    # Validate session
    session = await session_manager.get_session(session_code)
    if not session:
        await manager.send_personal_message({"type": "error", "payload": {"message": "Session not found"}}, websocket)
        return

    participants = session.get("participants", {})
    is_reconnecting = user_id in participants
    
    if session["status"] != "waiting" and not is_reconnecting:
        await manager.send_personal_message({"type": "error", "payload": {"message": "Session is already active"}}, websocket)
        return

    # Add or reconnect participant
    success = await session_manager.add_participant(session_code, user_id, username)
    if success:
        # Broadcast update
        session = await session_manager.get_session(session_code)
        await manager.broadcast_to_session({
            "type": "session_update",
            "payload": {
                "status": session["status"],
                "participant_count": len(session["participants"]),
                "participants": list(session["participants"].values())
            }
        }, session_code)
        
        # Send current state to user
        await manager.send_personal_message({
            "type": "session_state", 
            "payload": session
        }, websocket)
        
        # If reconnecting during active quiz, send current question
        if is_reconnecting and session["status"] == "active":
            question_data = await game_controller.get_current_question(session_code)
            if question_data:
                await manager.send_personal_message({
                    "type": "question",
                    "payload": question_data
                }, websocket)

async def handle_submit_answer(session_code: str, user_id: str, payload: dict):
    answer = payload.get("answer")
    timestamp = payload.get("timestamp")
    
    result = await game_controller.submit_answer(session_code, user_id, answer, timestamp)
    
    if "error" in result:
        # Send error to user
        user_ws = manager.user_connections.get(user_id)
        if user_ws:
            await manager.send_personal_message({"type": "error", "payload": {"message": result["error"]}}, user_ws)
        return

    # Update leaderboard
    if "new_total_score" in result:
        await leaderboard_manager.update_score(session_code, user_id, result["new_total_score"])

    # Send result to user
    user_ws = manager.user_connections.get(user_id)
    if user_ws:
        await manager.send_personal_message({
            "type": "answer_result",
            "payload": result
        }, user_ws)

    # Check if all answered
    if await game_controller.check_all_answered(session_code):
        # Reveal answer
        await reveal_answer(session_code)

async def reveal_answer(session_code: str):
    # Get current question info for correct answer
    question_data = await game_controller.get_current_question(session_code)
    if not question_data:
        return

    correct_answer = question_data["question"].get("correct_answer")
    
    # Get answer distribution statistics
    distribution = await game_controller.get_answer_distribution(session_code)
    
    # Get leaderboard
    rankings = await leaderboard_manager.get_rankings(session_code)
    
    # Broadcast reveal
    await manager.broadcast_to_session({
        "type": "answer_reveal",
        "payload": {
            "correct_answer": correct_answer,
            "answer_distribution": distribution,
            "rankings": rankings
        }
    }, session_code)
    
    import asyncio
    asyncio.create_task(delayed_advance(session_code))

async def delayed_advance(session_code: str):
    import asyncio
    await asyncio.sleep(5)
    
    # Check if there are more questions
    session = await session_manager.get_session(session_code)
    current_index = session.get("current_question_index", 0)
    total_questions = session.get("total_questions", 0)
    
    if current_index + 1 < total_questions:
        # Advance to next question
        await game_controller.advance_question(session_code)
        question_data = await game_controller.get_current_question(session_code)
        if question_data:
            await manager.broadcast_to_session({
                "type": "question",
                "payload": question_data
            }, session_code)
    else:
        # End quiz - calculate final results
        await complete_quiz(session_code)

async def handle_start_quiz(session_code: str, user_id: str):
    if await session_manager.is_host(session_code, user_id):
        # Validate minimum 2 participants
        session = await session_manager.get_session(session_code)
        participants = session.get("participants", {})
        connected_count = sum(1 for p in participants.values() if p.get("connected", False))
        
        if connected_count < 2:
            user_ws = manager.user_connections.get(user_id)
            if user_ws:
                await manager.send_personal_message({
                    "type": "error",
                    "payload": {"message": "At least 2 participants required to start"}
                }, user_ws)
            return
        
        success = await session_manager.start_session(session_code, user_id)
        if success:
            # Broadcast start
            await manager.broadcast_to_session({"type": "quiz_started"}, session_code)
            
            # Start question timer
            await game_controller.start_question_timer(session_code)
            
            # Send first question
            question_data = await game_controller.get_current_question(session_code)
            if question_data:
                await manager.broadcast_to_session({
                    "type": "question",
                    "payload": question_data
                }, session_code)

async def complete_quiz(session_code: str):
    """Complete quiz and persist results"""
    from app.core.database import live_game_results_collection
    from datetime import datetime
    
    await session_manager.end_session(session_code)
    session = await session_manager.get_session(session_code)
    
    # Calculate final rankings with accuracy
    rankings = await leaderboard_manager.get_rankings(session_code, limit=50)
    
    # Add accuracy to rankings
    for rank in rankings:
        accuracy = await game_controller.calculate_accuracy(session_code, rank["user_id"])
        rank["accuracy"] = round(accuracy, 2)
    
    # Persist to MongoDB
    result_doc = {
        "session_code": session_code,
        "quiz_id": session.get("quiz_id"),
        "host_id": session.get("host_id"),
        "participants": session.get("participants"),
        "rankings": rankings,
        "completed_at": datetime.utcnow(),
        "created_at": session.get("created_at")
    }
    await live_game_results_collection.insert_one(result_doc)
    
    # Broadcast final results
    await manager.broadcast_to_session({
        "type": "quiz_completed",
        "payload": {"final_rankings": rankings}
    }, session_code)
    
    # Schedule cleanup after 5 minutes
    import asyncio
    asyncio.create_task(cleanup_session(session_code))

async def cleanup_session(session_code: str):
    """Clean up session data after delay"""
    import asyncio
    await asyncio.sleep(300)  # 5 minutes
    
    # Clear Redis data
    from app.core.database import redis_client
    await redis_client.delete(f"session:{session_code}")
    await leaderboard_manager.clear_leaderboard(session_code)
    logger.info(f"Cleaned up session {session_code}")

async def handle_end_quiz(session_code: str, user_id: str):
    if await session_manager.is_host(session_code, user_id):
        await complete_quiz(session_code)

async def handle_disconnect(session_code: str, user_id: str):
    from datetime import datetime
    from app.core.database import redis_client
    
    # Mark as disconnected with timestamp
    await session_manager.remove_participant(session_code, user_id)
    
    # Store disconnection time for 60-second window
    disconnect_key = f"disconnect:{session_code}:{user_id}"
    await redis_client.setex(disconnect_key, 60, datetime.utcnow().isoformat())
    
    # Broadcast update
    session = await session_manager.get_session(session_code)
    if session:
        await manager.broadcast_to_session({
            "type": "session_update",
            "payload": {
                "status": session["status"],
                "participant_count": len(session["participants"]),
                "participants": list(session["participants"].values())
            }
        }, session_code)
    
    # Schedule auto-fail if not reconnected
    import asyncio
    asyncio.create_task(handle_prolonged_disconnect(session_code, user_id))

async def handle_prolonged_disconnect(session_code: str, user_id: str):
    """Mark remaining answers as incorrect if disconnected > 60 seconds"""
    import asyncio
    from app.core.database import redis_client
    
    await asyncio.sleep(60)
    
    # Check if still disconnected
    disconnect_key = f"disconnect:{session_code}:{user_id}"
    if await redis_client.exists(disconnect_key):
        session = await session_manager.get_session(session_code)
        if session and session.get("status") == "active":
            # User didn't reconnect - they're out
            logger.info(f"User {user_id} failed to reconnect to {session_code} within 60s")
            # Participant remains in session but marked as disconnected
