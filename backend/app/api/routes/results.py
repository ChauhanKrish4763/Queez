from fastapi import APIRouter, HTTPException
from datetime import datetime
from bson import ObjectId

from app.core.database import results_collection

router = APIRouter(prefix="/results", tags=["results"])

@router.post("")
async def submit_quiz_result(result_data: dict):
    """Submit quiz results"""
    try:
        result = {
            "quiz_id": result_data.get("quiz_id", ""),
            "user_id": result_data.get("user_id", "anonymous"),
            "username": result_data.get("username", "Anonymous User"),
            "score": result_data.get("score", 0),
            "total_questions": result_data.get("total_questions", 0),
            "percentage": result_data.get("percentage", 0),
            "time_taken": result_data.get("time_taken", 0),  # in seconds
            "submitted_at": datetime.utcnow().isoformat()
        }
        
        insert_result = await results_collection.insert_one(result)
        
        return {
            "success": True,
            "message": "Result submitted successfully",
            "result_id": str(insert_result.inserted_id),
            "score": result["score"],
            "percentage": result["percentage"]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{quiz_id}")
async def get_quiz_results(quiz_id: str, limit: int = 50):
    """Get all results for a quiz"""
    try:
        cursor = results_collection.find({"quiz_id": quiz_id}).sort("submitted_at", -1).limit(limit)
        results = await cursor.to_list(length=limit)
        
        result_list = [
            {
                "result_id": str(result["_id"]),
                "user_id": result.get("user_id", ""),
                "username": result.get("username", "Anonymous"),
                "score": result.get("score", 0),
                "total_questions": result.get("total_questions", 0),
                "percentage": result.get("percentage", 0),
                "time_taken": result.get("time_taken", 0),
                "submitted_at": result.get("submitted_at", "")
            }
            for result in results
        ]
        
        return {
            "success": True,
            "quiz_id": quiz_id,
            "count": len(result_list),
            "results": result_list
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
