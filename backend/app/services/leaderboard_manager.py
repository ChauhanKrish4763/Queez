import logging
import json
from typing import List, Dict, Any
from app.core.database import redis_client

logger = logging.getLogger(__name__)

class LeaderboardManager:
    def __init__(self):
        self.redis = redis_client

    async def get_leaderboard(self, session_code: str) -> List[Dict[str, Any]]:
        """
        Get real-time leaderboard for a session
        Returns sorted list of participants with rankings
        """
        session_key = f"session:{session_code}"
        
        # Get participants and current question index
        session_data = await self.redis.hmget(
            session_key, 
            ["participants", "current_question_index", "total_questions"]
        )
        
        if not session_data[0]:
            logger.warning(f"No participants found for session {session_code}")
            return []
        
        participants = json.loads(session_data[0])
        current_index = int(session_data[1] or 0)
        total_questions = int(session_data[2] or 0)
        
        # Build leaderboard data
        leaderboard = []
        for user_id, participant in participants.items():
            # Count answered questions
            answered_count = len(participant.get("answers", []))
            
            leaderboard.append({
                "user_id": user_id,
                "username": participant.get("username", "Anonymous"),
                "score": participant.get("score", 0),
                "answered_count": answered_count,
                "total_questions": total_questions,
                "current_question": current_index + 1,
                "is_connected": participant.get("connected", False),
            })
        
        # Sort by score (descending), then by answered_count (ascending - faster is better)
        leaderboard.sort(key=lambda x: (-x["score"], x["answered_count"]))
        
        # Add position/rank
        for idx, entry in enumerate(leaderboard):
            entry["position"] = idx + 1
        
        logger.info(f"📊 Leaderboard for {session_code}: {len(leaderboard)} participants")
        
        return leaderboard

    async def get_participant_rank(self, session_code: str, user_id: str) -> Dict[str, Any]:
        """Get rank info for a specific participant"""
        leaderboard = await self.get_leaderboard(session_code)
        
        for entry in leaderboard:
            if entry["user_id"] == user_id:
                return {
                    "position": entry["position"],
                    "score": entry["score"],
                    "total_participants": len(leaderboard)
                }
        
        return {"position": None, "score": 0, "total_participants": len(leaderboard)}

    async def calculate_final_results(self, session_code: str) -> List[Dict[str, Any]]:
        """Calculate final results with additional stats"""
        leaderboard = await self.get_leaderboard(session_code)
        
        # Add accuracy and performance metrics
        for entry in leaderboard:
            user_id = entry["user_id"]
            
            # Get participant answers
            session_key = f"session:{session_code}"
            participants_json = await self.redis.hget(session_key, "participants")
            participants = json.loads(participants_json)
            
            if user_id in participants:
                participant = participants[user_id]
                answers = participant.get("answers", [])
                
                # Calculate accuracy
                if answers:
                    correct_count = sum(1 for ans in answers if ans.get("is_correct", False))
                    entry["accuracy"] = round((correct_count / len(answers)) * 100, 1)
                    entry["correct_answers"] = correct_count
                    entry["wrong_answers"] = len(answers) - correct_count
                else:
                    entry["accuracy"] = 0.0
                    entry["correct_answers"] = 0
                    entry["wrong_answers"] = 0
        
        return leaderboard

    async def get_final_results(self, session_code: str) -> List[Dict[str, Any]]:
        """Get final results - alias for calculate_final_results"""
        return await self.calculate_final_results(session_code)
