import json
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List
import random
import string

from app.core.database import redis_client, collection as quiz_collection, results_collection
from app.core.config import SESSION_EXPIRY_HOURS
from bson import ObjectId

logger = logging.getLogger(__name__)

class SessionManager:
    def __init__(self):
        self.redis = redis_client

    async def create_session(self, quiz_id: str, host_id: str, mode: str = "live") -> str:
        """Create a new session and return the session code"""
        # Generate unique code
        session_code = await self._generate_unique_code()
        
        # Fetch quiz details to cache basic info
        quiz = await quiz_collection.find_one({"_id": ObjectId(quiz_id)})
        if not quiz:
            raise ValueError("Quiz not found")

        # Initialize session state in Redis
        session_data = {
            "session_code": session_code,
            "quiz_id": quiz_id,
            "host_id": host_id,
            "status": "waiting",  # waiting, active, completed
            "mode": mode,
            "current_question_index": 0,
            "created_at": datetime.utcnow().isoformat(),
            "expires_at": (datetime.utcnow() + timedelta(hours=SESSION_EXPIRY_HOURS)).isoformat(),
            "quiz_title": quiz.get("title", "Untitled Quiz"),
            "total_questions": len(quiz.get("questions", [])),
            "participants": "{}"  # JSON string of participant dict
        }
        
        # Store in Redis with expiration
        await self.redis.hset(f"session:{session_code}", mapping=session_data)
        await self.redis.expire(f"session:{session_code}", SESSION_EXPIRY_HOURS * 3600)
        
        return session_code

    async def _generate_unique_code(self) -> str:
        """Generate a unique 6-character alphanumeric code"""
        chars = string.ascii_uppercase + string.digits
        while True:
            code = ''.join(random.choices(chars, k=6))
            if not await self.redis.exists(f"session:{code}"):
                return code

    async def get_session(self, session_code: str) -> Optional[Dict[str, Any]]:
        """Retrieve session state from Redis"""
        session_data = await self.redis.hgetall(f"session:{session_code}")
        if not session_data:
            return None
            
        # Parse nested JSON fields
        if "participants" in session_data and isinstance(session_data["participants"], str):
            session_data["participants"] = json.loads(session_data["participants"])
            
        # Convert numeric fields
        if "current_question_index" in session_data:
            session_data["current_question_index"] = int(session_data["current_question_index"])
        if "total_questions" in session_data:
            session_data["total_questions"] = int(session_data["total_questions"])
            
        return session_data

    async def add_participant(self, session_code: str, user_id: str, username: str) -> bool:
        """Add a participant to the session (excluding host)"""
        session_key = f"session:{session_code}"
        
        # Check if user is the host - hosts should NOT be in participant list
        host_id = await self.redis.hget(session_key, "host_id")
        if user_id == host_id:
            logger.info(f"Rejected participant join: {user_id} is the host of session {session_code}")
            return False
        
        # Get current participants
        participants_json = await self.redis.hget(session_key, "participants")
        if not participants_json:
            return False
            
        participants = json.loads(participants_json)
        
        # Add or update participant
        if user_id in participants:
            # Reconnecting user - preserve state
            participants[user_id]["connected"] = True
            participants[user_id]["username"] = username # Update username just in case
        else:
            # New participant
            participants[user_id] = {
                "user_id": user_id,
                "username": username,
                "joined_at": datetime.utcnow().isoformat(),
                "connected": True,
                "score": 0,
                "answers": []
            }
        
        await self.redis.hset(session_key, "participants", json.dumps(participants))
        return True

    async def remove_participant(self, session_code: str, user_id: str):
        """Mark participant as disconnected"""
        session_key = f"session:{session_code}"
        participants_json = await self.redis.hget(session_key, "participants")
        if participants_json:
            participants = json.loads(participants_json)
            if user_id in participants:
                participants[user_id]["connected"] = False
                await self.redis.hset(session_key, "participants", json.dumps(participants))

    async def start_session(self, session_code: str, host_id: str) -> bool:
        """Transition session to active state"""
        logger.info(f"🎮 Starting session {session_code} by host {host_id}")
        
        session = await self.get_session(session_code)
        if not session:
            logger.error(f"❌ Session {session_code} not found!")
            return False
            
        if session["host_id"] != host_id:
            logger.error(f"❌ User {host_id} is not the host (actual host: {session['host_id']})")
            return False
        
        logger.info(f"✅ Setting session {session_code} status to 'active'")
        logger.info(f"📊 Session data: quiz_id={session.get('quiz_id')}, participants={len(session.get('participants', {}))}")
        
        await self.redis.hset(f"session:{session_code}", "status", "active")
        return True

    async def end_session(self, session_code: str) -> bool:
        """Mark session as completed"""
        await self.redis.hset(f"session:{session_code}", "status", "completed")
        return True

    async def is_host(self, session_code: str, user_id: str) -> bool:
        """Check if user is the host"""
        host_id = await self.redis.hget(f"session:{session_code}", "host_id")
        return host_id == user_id
