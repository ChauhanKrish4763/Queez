from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta
from bson import ObjectId

from app.models.session import SessionCreate, SessionResponse, SessionInfo, ParticipantJoin
from app.core.database import collection, sessions_collection, session_participants_collection
from app.utils.helpers import generate_session_code

router = APIRouter(prefix="/api", tags=["sessions"])

@router.post("/quiz/{quiz_id}/create-session", response_model=SessionResponse)
async def create_quiz_session(quiz_id: str, session_data: SessionCreate):
    """Create a new quiz session with a unique code (valid for 10 minutes)"""
    try:
        # Verify quiz exists
        quiz = await collection.find_one({"_id": ObjectId(quiz_id)})
        if not quiz:
            raise HTTPException(status_code=404, detail="Quiz not found")
        
        # Generate unique session code
        session_code = generate_session_code()
        
        # Ensure uniqueness
        while await sessions_collection.find_one({"session_code": session_code}):
            session_code = generate_session_code()
        
        # Calculate expiration (10 minutes from now)
        created_at = datetime.utcnow()
        expires_at = created_at + timedelta(minutes=10)
        expires_in = 600  # 10 minutes in seconds
        
        # Create session document
        session = {
            "session_code": session_code,
            "quiz_id": quiz_id,
            "host_id": session_data.host_id,
            "mode": session_data.mode,
            "is_active": True,
            "is_started": False,
            "participant_count": 0,
            "created_at": created_at,
            "expires_at": expires_at,  # TTL index will auto-delete after this time
            "quiz_title": quiz.get("title", "Untitled Quiz")
        }
        
        await sessions_collection.insert_one(session)
        
        return SessionResponse(
            success=True,
            session_code=session_code,
            expires_in=expires_in,
            expires_at=expires_at.isoformat()
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating session: {str(e)}")


@router.get("/session/{session_code}", response_model=SessionInfo)
async def get_session_info(session_code: str):
    """Get session information and validate if it exists and is not expired"""
    try:
        session = await sessions_collection.find_one({"session_code": session_code})
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found or expired")
        
        # Check if expired (belt-and-suspenders check, TTL index should handle this)
        if session["expires_at"] < datetime.utcnow():
            await sessions_collection.delete_one({"session_code": session_code})
            raise HTTPException(status_code=410, detail="Session has expired")
        
        # Count participants
        participant_count = await session_participants_collection.count_documents(
            {"session_code": session_code}
        )
        
        return SessionInfo(
            success=True,
            session_code=session_code,
            quiz_id=session["quiz_id"],
            host_id=session["host_id"],
            mode=session["mode"],
            participant_count=participant_count,
            is_active=session.get("is_active", True),
            is_started=session.get("is_started", False),
            created_at=session["created_at"].isoformat(),
            expires_at=session["expires_at"].isoformat()
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving session: {str(e)}")


@router.get("/session/{session_code}/participants")
async def get_session_participants(session_code: str):
    """Get the number of participants who have joined the session"""
    try:
        # Verify session exists
        session = await sessions_collection.find_one({"session_code": session_code})
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found or expired")
        
        # Check if expired
        if session["expires_at"] < datetime.utcnow():
            raise HTTPException(status_code=410, detail="Session has expired")
        
        # Count participants
        participant_count = await session_participants_collection.count_documents(
            {"session_code": session_code}
        )
        
        # Get participant list (optional, for debugging)
        cursor = session_participants_collection.find({"session_code": session_code})
        participants = await cursor.to_list(length=None)
        
        participant_list = [
            {
                "user_id": p.get("user_id", ""),
                "username": p.get("username", "Anonymous"),
                "joined_at": p.get("joined_at", "")
            }
            for p in participants
        ]
        
        return {
            "success": True,
            "session_code": session_code,
            "participant_count": participant_count,
            "participants": participant_list,
            "mode": session.get("mode", ""),
            "is_started": session.get("is_started", False)
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving participants: {str(e)}")


@router.post("/session/{session_code}/join")
async def join_session(session_code: str, participant: ParticipantJoin):
    """Join a quiz session as a participant"""
    try:
        # Verify session exists and is not expired
        session = await sessions_collection.find_one({"session_code": session_code})
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found or expired")
        
        if session["expires_at"] < datetime.utcnow():
            raise HTTPException(status_code=410, detail="Session has expired")
        
        if session.get("is_started", False):
            raise HTTPException(status_code=400, detail="Quiz has already started")
        
        # Check if user already joined
        existing = await session_participants_collection.find_one({
            "session_code": session_code,
            "user_id": participant.user_id
        })
        
        if existing:
            return {
                "success": True,
                "message": "Already joined this session",
                "session_code": session_code
            }
        
        # Add participant
        participant_doc = {
            "session_code": session_code,
            "user_id": participant.user_id,
            "username": participant.username,
            "joined_at": datetime.utcnow().isoformat()
        }
        
        await session_participants_collection.insert_one(participant_doc)
        
        # Update participant count in session
        new_count = await session_participants_collection.count_documents(
            {"session_code": session_code}
        )
        await sessions_collection.update_one(
            {"session_code": session_code},
            {"$set": {"participant_count": new_count}}
        )
        
        return {
            "success": True,
            "message": "Successfully joined the session",
            "session_code": session_code,
            "participant_count": new_count,
            "quiz_id": session["quiz_id"]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error joining session: {str(e)}")


@router.post("/session/{session_code}/start")
async def start_quiz_session(session_code: str, host_id: str):
    """Start the quiz session (only host can start)"""
    try:
        session = await sessions_collection.find_one({"session_code": session_code})
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found or expired")
        
        # Verify host
        if session["host_id"] != host_id:
            raise HTTPException(status_code=403, detail="Only the host can start the quiz")
        
        if session.get("is_started", False):
            return {
                "success": True,
                "message": "Quiz already started",
                "session_code": session_code
            }
        
        # Update session status
        await sessions_collection.update_one(
            {"session_code": session_code},
            {"$set": {"is_started": True, "started_at": datetime.utcnow()}}
        )
        
        participant_count = await session_participants_collection.count_documents(
            {"session_code": session_code}
        )
        
        return {
            "success": True,
            "message": "Quiz started successfully",
            "session_code": session_code,
            "participant_count": participant_count,
            "mode": session["mode"]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error starting session: {str(e)}")


@router.post("/session/{session_code}/end")
async def end_quiz_session(session_code: str, host_id: str):
    """End the quiz session (only host can end)"""
    try:
        session = await sessions_collection.find_one({"session_code": session_code})
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        
        # Verify host
        if session["host_id"] != host_id:
            raise HTTPException(status_code=403, detail="Only the host can end the quiz")
        
        # Update session status
        await sessions_collection.update_one(
            {"session_code": session_code},
            {"$set": {"is_active": False, "ended_at": datetime.utcnow()}}
        )
        
        # Optionally: Clean up participants
        # await session_participants_collection.delete_many({"session_code": session_code})
        
        return {
            "success": True,
            "message": "Quiz session ended successfully",
            "session_code": session_code
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error ending session: {str(e)}")


@router.delete("/session/{session_code}")
async def delete_session(session_code: str, host_id: str):
    """Delete a session (cleanup)"""
    try:
        session = await sessions_collection.find_one({"session_code": session_code})
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        
        # Verify host
        if session["host_id"] != host_id:
            raise HTTPException(status_code=403, detail="Only the host can delete the session")
        
        # Delete session and participants
        await sessions_collection.delete_one({"session_code": session_code})
        await session_participants_collection.delete_many({"session_code": session_code})
        
        return {
            "success": True,
            "message": "Session deleted successfully"
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting session: {str(e)}")
