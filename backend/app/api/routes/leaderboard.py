from fastapi import APIRouter, HTTPException

from app.core.database import results_collection

router = APIRouter(prefix="/leaderboard", tags=["leaderboard"])

@router.get("/{quiz_id}")
async def get_leaderboard(quiz_id: str, limit: int = 10):
    """Get leaderboard for a quiz (top scores)"""
    try:
        # Get top scores
        cursor = results_collection.find({"quiz_id": quiz_id}).sort([("score", -1), ("time_taken", 1)]).limit(limit)
        results = await cursor.to_list(length=limit)
        
        leaderboard = []
        for rank, result in enumerate(results, start=1):
            leaderboard.append({
                "rank": rank,
                "user_id": result.get("user_id", ""),
                "username": result.get("username", "Anonymous"),
                "score": result.get("score", 0),
                "total_questions": result.get("total_questions", 0),
                "percentage": result.get("percentage", 0),
                "time_taken": result.get("time_taken", 0),
                "submitted_at": result.get("submitted_at", "")
            })
        
        return {
            "success": True,
            "quiz_id": quiz_id,
            "leaderboard": leaderboard
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
