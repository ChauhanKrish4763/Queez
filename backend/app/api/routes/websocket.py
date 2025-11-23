from datetime import datetime
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

@router.websocket("/api/ws/{session_code}")
async def websocket_endpoint(websocket: WebSocket, session_code: str, user_id: str = Query(...)):
    """
    WebSocket endpoint for real-time quiz sessions
    """
    # === CRITICAL: Accept connection FIRST ===
    try:
        await websocket.accept()
        logger.info(f"WebSocket accepted for session={session_code}, user={user_id}")
    except Exception as e:
        logger.error(f"Failed to accept WebSocket: {e}")
        return

    # Check if user is host
    is_host = await session_manager.is_host(session_code, user_id)
    
    # Register connection
    await manager.connect(websocket, session_code, user_id, is_host)
    logger.info(f"Connection registered for user={user_id}, is_host={is_host}")

    try:
        # Listen for messages
        async for message_data in websocket.iter_text():
            try:
                message = json.loads(message_data)
                message_type = message.get("type")
                payload = message.get("payload", {})
                
                logger.info(f"📨 Received message type={message_type} from user={user_id}")

                if message_type == "join":
                    await handle_join(websocket, session_code, user_id, payload)
                
                elif message_type == "start_quiz":
                    await handle_start_quiz(websocket, session_code, user_id)
                
                elif message_type == "submit_answer":
                    logger.info(f"📝 Processing submit_answer from {user_id}")
                    await handle_submit_answer(websocket, session_code, user_id, payload)
                
                elif message_type == "next_question":
                    await handle_next_question(websocket, session_code, user_id)
                
                elif message_type == "request_next_question":
                    await handle_request_next_question(websocket, session_code, user_id)
                
                elif message_type == "end_quiz":
                    await handle_end_quiz(websocket, session_code, user_id)
                
                else:
                    logger.warning(f"Unknown message type: {message_type}")

            except json.JSONDecodeError as e:
                logger.error(f"Invalid JSON: {e}")
            except Exception as e:
                logger.error(f"Error processing message: {e}")

    except WebSocketDisconnect:
        logger.info(f"WebSocket disconnected for user={user_id}")
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
    finally:
        manager.disconnect(websocket, session_code, user_id)  # ✅ NO await!
        logger.info(f"User {user_id} disconnected from session {session_code}")


async def handle_join(websocket: WebSocket, session_code: str, user_id: str, payload: dict):
    username = payload.get("username", "Anonymous")
    
    logger.info(f"📨 JOIN request - session={session_code}, user={user_id}, username={username}")
    
    # Validate session
    session = await session_manager.get_session(session_code)
    if not session:
        logger.error(f"❌ Session {session_code} not found!")
        await manager.send_personal_message({"type": "error", "payload": {"message": "Session not found"}}, websocket)
        return
    
    logger.info(f"✅ Session {session_code} found. Current status: {session.get('status')}")
    
    # ✅ CHECK IF USER IS HOST FIRST
    is_host = await session_manager.is_host(session_code, user_id)
    
    if is_host:
        # Host is joining - send session state without adding to participants
        logger.info(f"✅ HOST {user_id} ({username}) joining their own session {session_code}")
        
        # Prepare session payload with participants as list
        session_payload = {**session}
        participants_list = list(session.get("participants", {}).values())
        session_payload["participants"] = participants_list
        
        # ✅ ADD participant_count for Flutter
        session_payload["participant_count"] = len(participants_list)
        
        logger.info(f"📊 HOST - Current participants: {len(participants_list)}")
        for p in participants_list:
            logger.info(f"   - {p.get('username', 'Unknown')} (ID: {p.get('user_id', 'Unknown')})")
        
        # Send session state to host
        await manager.send_personal_message({
            "type": "session_state",
            "payload": session_payload
        }, websocket)
        
        logger.info(f"✅ Sent session_state to HOST {user_id}")
        return  # Done - host doesn't get added to participants
    
    # ✅ REGULAR PARTICIPANT LOGIC BELOW
    logger.info(f"👤 PARTICIPANT {user_id} ({username}) joining session {session_code}")
    participants = session.get("participants", {})
    is_reconnecting = user_id in participants
    
    if is_reconnecting:
        logger.info(f"🔄 User {user_id} is RECONNECTING")
    else:
        logger.info(f"🆕 User {user_id} is a NEW participant")
    
    # Check if session is still accepting new participants
    if session["status"] != "waiting" and not is_reconnecting:
        logger.warning(f"❌ Session {session_code} is {session['status']}, cannot accept new participants")
        await manager.send_personal_message({"type": "error", "payload": {"message": "Session is already active"}}, websocket)
        return
    
    # Add or reconnect participant
    success = await session_manager.add_participant(session_code, user_id, username)
    
    if success:
        logger.info(f"✅ Successfully added {username} (ID: {user_id}) to session {session_code}")
        
        # Broadcast update to all
        session = await session_manager.get_session(session_code)
        participants_list = list(session["participants"].values())
        
        logger.info(f"📡 Broadcasting session_update to all connections in {session_code}")
        logger.info(f"📊 Total participants after join: {len(participants_list)}")
        
        await manager.broadcast_to_session({
            "type": "session_update",
            "payload": {
                "status": session["status"],
                "participant_count": len(participants_list),
                "participants": participants_list
            }
        }, session_code)
        
        logger.info(f"✅ Broadcast complete for session {session_code}")
        
        # Send current state to this participant
        session_payload = {**session}
        session_payload["participants"] = participants_list
        
        # ✅ ADD participant_count for Flutter
        session_payload["participant_count"] = len(participants_list)
        
        await manager.send_personal_message({
            "type": "session_state",
            "payload": session_payload
        }, websocket)
        
        logger.info(f"✅ Sent session_state to participant {user_id}")
        
        # If reconnecting during active quiz, send current question
        if is_reconnecting and session["status"] == "active":
            logger.info(f"🎮 Sending current question to reconnecting user {user_id}")
            question_data = await game_controller.get_current_question(session_code)
            if question_data:
                await manager.send_personal_message({
                    "type": "question",
                    "payload": question_data
                }, websocket)
                logger.info(f"✅ Sent current question to {user_id}")
    else:
        logger.error(f"❌ Failed to add {username} (ID: {user_id}) to session {session_code}")


async def handle_start_quiz(websocket: WebSocket, session_code: str, user_id: str):
    """Host starts the quiz"""
    is_host = await session_manager.is_host(session_code, user_id)
    
    if not is_host:
        await manager.send_personal_message({
            "type": "error",
            "payload": {"message": "Only host can start the quiz"}
        }, websocket)
        return
    
    # Start the quiz - update session status
    success = await session_manager.start_session(session_code, user_id)
    if not success:
        await manager.send_personal_message({
            "type": "error",
            "payload": {"message": "Failed to start session"}
        }, websocket)
        return
    
    # Initialize all participants to question 0
    session = await session_manager.get_session(session_code)
    participants = session.get("participants", {})
    
    for participant_id in participants.keys():
        await game_controller.set_participant_question_index(session_code, participant_id, 0)
        logger.info(f"📝 Initialized participant {participant_id} to question 0")
    
    # Start the question timer
    await game_controller.start_question_timer(session_code)
    
    # Get first question (index 0)
    question_data = await game_controller.get_question_by_index(session_code, 0)
    
    if not question_data:
        await manager.send_personal_message({
            "type": "error",
            "payload": {"message": "No questions available"}
        }, websocket)
        return
    
    # Broadcast quiz started to all participants
    await manager.broadcast_to_session({
        "type": "quiz_started",
        "payload": {"message": "Quiz is starting!"}
    }, session_code)
    
    # Send first question to all participants
    await manager.broadcast_to_session({
        "type": "question",
        "payload": question_data
    }, session_code)



async def handle_submit_answer(websocket: WebSocket, session_code: str, user_id: str, payload: dict):
    """Participant submits an answer"""
    answer = payload.get("answer")
    timestamp = payload.get("timestamp", datetime.utcnow().timestamp())
    
    if answer is None:
        logger.error(f"❌ ANSWER - No answer provided in payload: {payload}")
        await manager.send_personal_message({
            "type": "error",
            "payload": {"message": "Invalid answer submission"}
        }, websocket)
        return
    
    logger.info(f"📝 ANSWER - User {user_id} submitted answer: {answer} (timestamp: {timestamp})")
    
    # Process answer
    result = await game_controller.submit_answer(
        session_code, user_id, answer, timestamp
    )
    
    is_correct = result.get('is_correct', False)
    points = result.get('points', 0)
    logger.info(f"{'✅' if is_correct else '❌'} ANSWER - Result for {user_id}: {'CORRECT' if is_correct else 'INCORRECT'}, Points: {points}")
    
    # Send result to participant
    await manager.send_personal_message({
        "type": "answer_result",
        "payload": result
    }, websocket)
    logger.info(f"📤 ANSWER - Sent answer result to {user_id}")
    
    # ✅ GET AND BROADCAST REAL-TIME LEADERBOARD
    leaderboard = await leaderboard_manager.get_leaderboard(session_code)
    logger.info(f"🏆 LEADERBOARD - Broadcasting update to session {session_code} ({len(leaderboard)} participants)")
    
    await manager.broadcast_to_session({
        "type": "leaderboard_update",
        "payload": {"leaderboard": leaderboard}
    }, session_code)
    
    logger.info(f"✅ LEADERBOARD - Broadcast complete for session {session_code}")


async def handle_next_question(websocket: WebSocket, session_code: str, user_id: str):
    """Host moves to next question (broadcast to all)"""
    is_host = await session_manager.is_host(session_code, user_id)
    
    if not is_host:
        await manager.send_personal_message({
            "type": "error",
            "payload": {"message": "Only host can control questions"}
        }, websocket)
        return
    
    # Get next question
    question_data = await game_controller.next_question(session_code)
    
    if question_data:
        # Send next question
        await manager.broadcast_to_session({
            "type": "question",
            "payload": question_data
        }, session_code)
    else:
        # No more questions - quiz complete
        await handle_end_quiz(websocket, session_code, user_id)


async def handle_request_next_question(websocket: WebSocket, session_code: str, user_id: str):
    """Participant requests their next question (self-paced)"""
    logger.info(f"📨 SELF_PACED - Participant {user_id} requesting next question")
    
    # Get participant's current progress
    participant_question_index = await game_controller.get_participant_question_index(session_code, user_id)
    total_questions = await game_controller.get_total_questions(session_code)
    
    logger.info(f"📊 SELF_PACED - Current index for {user_id}: {participant_question_index}/{total_questions}")
    logger.info(f"🔍 SELF_PACED - Checking completion: {participant_question_index} >= {total_questions - 1} = {participant_question_index >= total_questions - 1}")
    
    # Check if participant has already completed all questions
    if participant_question_index >= total_questions - 1:
        logger.info(f"🏁 SELF_PACED - ✅ COMPLETION TRIGGERED! Participant {user_id} has completed all questions!")
        
        # Get final results
        final_results = await leaderboard_manager.get_final_results(session_code)
        
        await manager.send_personal_message({
            "type": "quiz_completed",
            "payload": {
                "message": "You've completed all questions!",
                "results": final_results
            }
        }, websocket)
        logger.info(f"✅ SELF_PACED - Sent completion message to {user_id}")
        return
    
    # Increment their question index
    next_index = participant_question_index + 1
    await game_controller.set_participant_question_index(session_code, user_id, next_index)
    
    logger.info(f"➡️ SELF_PACED - Participant {user_id} advancing: Q{participant_question_index} → Q{next_index}")
    
    # Get the next question for this participant
    question_data = await game_controller.get_question_by_index(session_code, next_index)
    
    if question_data:
        # Send next question to this participant only
        logger.info(f"📤 SELF_PACED - Sending Q{next_index + 1}/{total_questions} to participant {user_id}")
        await manager.send_personal_message({
            "type": "question",
            "payload": question_data
        }, websocket)
        logger.info(f"✅ SELF_PACED - Successfully sent Q{next_index + 1} to {user_id}")
    else:
        # No more questions - participant finished
        logger.info(f"🏁 SELF_PACED - Participant {user_id} completed all questions!")
        
        # Get final results
        final_results = await leaderboard_manager.get_final_results(session_code)
        
        await manager.send_personal_message({
            "type": "quiz_completed",
            "payload": {
                "message": "You've completed all questions!",
                "results": final_results
            }
        }, websocket)
        logger.info(f"✅ SELF_PACED - Sent completion message to {user_id}")


async def handle_end_quiz(websocket: WebSocket, session_code: str, user_id: str):
    """Host ends the quiz or quiz completes naturally"""
    is_host = await session_manager.is_host(session_code, user_id)
    
    if not is_host:
        await manager.send_personal_message({
            "type": "error",
            "payload": {"message": "Only host can end the quiz"}
        }, websocket)
        return
    
    # Mark session as completed
    await session_manager.complete_session(session_code)
    
    # Get final results
    final_results = await leaderboard_manager.get_final_results(session_code)
    
    # Broadcast quiz end
    await manager.broadcast_to_session({
        "type": "quiz_ended",
        "payload": {
            "message": "Quiz completed!",
            "results": final_results
        }
    }, session_code)
