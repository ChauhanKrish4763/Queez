from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
import logging

from app.services.session_manager import SessionManager
from app.core.database import collection
from bson import ObjectId

router = APIRouter(prefix="/api/multiplayer", tags=["live-multiplayer"])
logger = logging.getLogger(__name__)

session_manager = SessionManager()


class CreateLiveSessionRequest(BaseModel):
    quiz_id: str
    host_id: str
    mode: str = "live"


class CreateLiveSessionResponse(BaseModel):
    success: bool
    session_code: str
    message: str


@router.post("/create-session", response_model=CreateLiveSessionResponse)
async def create_live_session(request: CreateLiveSessionRequest):
    """
    Create a new live multiplayer session stored in Redis.
    This is different from the regular session endpoint which uses MongoDB.
    """
    try:
        # Verify quiz exists
        quiz = await collection.find_one({"_id": ObjectId(request.quiz_id)})
        if not quiz:
            raise HTTPException(status_code=404, detail="Quiz not found")
        
        # Create session in Redis
        session_code = await session_manager.create_session(
            quiz_id=request.quiz_id,
            host_id=request.host_id,
            mode=request.mode
        )
        
        logger.info(f"Created live session {session_code} for quiz {request.quiz_id}")
        
        return CreateLiveSessionResponse(
            success=True,
            session_code=session_code,
            message=f"Live session created successfully. Session code: {session_code}"
        )
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating live session: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error creating live session: {str(e)}")


@router.get("/session/{session_code}")
async def get_live_session(session_code: str):
    """Get live session information from Redis"""
    try:
        session = await session_manager.get_session(session_code)
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        
        return {
            "success": True,
            "session": session
        }
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting live session: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error retrieving session: {str(e)}")



class ParticipantJoin(BaseModel):
    user_id: str
    username: str


@router.get("/session/{session_code}/participants")
async def get_session_participants(session_code: str):
    """Get participants for a live multiplayer session from Redis"""
    try:
        session = await session_manager.get_session(session_code)
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found or expired")
        
        participants = session.get("participants", {})
        participant_list = [
            {
                "user_id": p.get("user_id", ""),
                "username": p.get("username", "Anonymous"),
                "joined_at": p.get("joined_at", ""),
                "score": p.get("score", 0),
                "connected": p.get("connected", False)
            }
            for p in participants.values()
        ]
        
        return {
            "success": True,
            "session_code": session_code,
            "participant_count": len(participants),
            "participants": participant_list,
            "mode": session.get("mode", ""),
            "is_started": session.get("status") == "active"
        }
    
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting participants: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error retrieving participants: {str(e)}")


@router.post("/session/{session_code}/join")
async def join_session(session_code: str, participant: ParticipantJoin):
    """Join a live session"""
    try:
        session = await session_manager.get_session(session_code)
        if not session:
            raise HTTPException(status_code=404, detail="Session not found or expired")
            
        if session.get("status") != "waiting":
             # Allow rejoining if already in participants
            participants = session.get("participants", {})
            if participant.user_id not in participants:
                raise HTTPException(status_code=400, detail="Quiz has already started")

        success = await session_manager.add_participant(
            session_code, 
            participant.user_id, 
            participant.username
        )
        
        if not success:
            raise HTTPException(status_code=500, detail="Failed to join session")
            
        # Get updated count
        session = await session_manager.get_session(session_code)
        participants = session.get("participants", {})
        
        return {
            "success": True,
            "message": "Successfully joined the session",
            "session_code": session_code,
            "participant_count": len(participants),
            "quiz_id": session["quiz_id"]
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error joining session: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error joining session: {str(e)}")


# Defining SessionAction model for start/end
class SessionAction(BaseModel):
    host_id: str

@router.post("/session/{session_code}/start")
async def start_quiz_session(session_code: str, action: SessionAction):
    try:
        session = await session_manager.get_session(session_code)
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
            
        if session["host_id"] != action.host_id:
            raise HTTPException(status_code=403, detail="Only host can start")
            
        success = await session_manager.start_session(session_code, action.host_id)
        if not success:
             raise HTTPException(status_code=400, detail="Failed to start session")
             
        return {
            "success": True,
            "message": "Quiz started successfully",
            "session_code": session_code
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error starting session: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error starting session: {str(e)}")


@router.post("/session/{session_code}/end")
async def end_quiz_session(session_code: str, action: SessionAction):
    try:
        session = await session_manager.get_session(session_code)
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
            
        if session["host_id"] != action.host_id:
            raise HTTPException(status_code=403, detail="Only host can end")
            
        success = await session_manager.end_session(session_code)
        
        return {
            "success": True,
            "message": "Quiz session ended",
            "session_code": session_code
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error ending session: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error ending session: {str(e)}")


@router.post("/session/{session_code}/validate")
async def validate_session(session_code: str):
    """Validate if a session code exists and is active"""
    try:
        session = await session_manager.get_session(session_code)
        
        if not session:
            return {
                "success": False,
                "valid": False,
                "message": "Session not found"
            }
        
        return {
            "success": True,
            "valid": True,
            "session_code": session_code,
            "status": session.get("status"),
            "quiz_title": session.get("quiz_title"),
            "participant_count": len(session.get("participants", {}))
        }
    
    except Exception as e:
        logger.error(f"Error validating session: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Error validating session: {str(e)}")
