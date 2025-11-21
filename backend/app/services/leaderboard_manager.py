from typing import List, Dict, Any
from app.core.database import redis_client

class LeaderboardManager:
    def __init__(self):
        self.redis = redis_client

    async def update_score(self, session_code: str, user_id: str, score: int):
        """Update a participant's score in the leaderboard"""
        leaderboard_key = f"leaderboard:{session_code}"
        await self.redis.zadd(leaderboard_key, {user_id: score})

    async def get_rankings(self, session_code: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Get top N participants"""
        leaderboard_key = f"leaderboard:{session_code}"
        # Get top users with scores
        top_users = await self.redis.zrevrange(leaderboard_key, 0, limit - 1, withscores=True)
        
        rankings = []
        for i, (user_id, score) in enumerate(top_users):
            rankings.append({
                "rank": i + 1,
                "user_id": user_id,
                "score": int(score)
            })
        return rankings
    
    async def get_rankings_with_usernames(self, session_code: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Get top N participants with usernames and current question progress from session data"""
        from app.services.session_manager import SessionManager
        import json
        
        session_manager = SessionManager()
        session = await session_manager.get_session(session_code)
        
        if not session:
            return []
        
        participants = session.get("participants", {})
        rankings = await self.get_rankings(session_code, limit)
        
        # Enrich with usernames and current question
        for rank_entry in rankings:
            user_id = rank_entry["user_id"]
            participant = participants.get(user_id, {})
            rank_entry["username"] = participant.get("username", "Unknown")
            
            # Track current question (based on number of answers submitted)
            answers = participant.get("answers", [])
            rank_entry["current_question"] = len(answers)
        
        return rankings

    async def get_user_rank(self, session_code: str, user_id: str) -> int:
        """Get specific user's rank (1-based)"""
        leaderboard_key = f"leaderboard:{session_code}"
        rank = await self.redis.zrevrank(leaderboard_key, user_id)
        return (rank + 1) if rank is not None else 0

    async def clear_leaderboard(self, session_code: str):
        """Delete leaderboard data"""
        leaderboard_key = f"leaderboard:{session_code}"
        await self.redis.delete(leaderboard_key)
