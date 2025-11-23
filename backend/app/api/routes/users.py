from fastapi import APIRouter, HTTPException
from datetime import datetime
from bson import ObjectId

from app.core.database import users_collection, collection

router = APIRouter(prefix="/users", tags=["users"])

@router.post("")
async def create_user(user_data: dict):
    """Create a new user profile"""
    try:
        user = {
            "username": user_data.get("username", ""),
            "email": user_data.get("email", ""),
            "full_name": user_data.get("full_name", ""),
            "avatar_url": user_data.get("avatar_url", "https://img.freepik.com/free-vector/user-icon-concept_78370-2554.jpg"),
            "bio": user_data.get("bio", ""),
            "created_at": datetime.utcnow().isoformat(),
            "quiz_count": 0,
            "total_attempts": 0
        }
        
        result = await users_collection.insert_one(user)
        
        return {
            "success": True,
            "message": "User created successfully",
            "user_id": str(result.inserted_id)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{user_id}")
async def get_user(user_id: str):
    """Get user profile"""
    try:
        user = await users_collection.find_one({"_id": ObjectId(user_id)})
        
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {
            "success": True,
            "user": {
                "user_id": str(user["_id"]),
                "username": user.get("username", ""),
                "email": user.get("email", ""),
                "full_name": user.get("full_name", ""),
                "avatar_url": user.get("avatar_url", ""),
                "bio": user.get("bio", ""),
                "created_at": user.get("created_at", ""),
                "quiz_count": user.get("quiz_count", 0),
                "total_attempts": user.get("total_attempts", 0)
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{user_id}")
async def update_user(user_id: str, user_data: dict):
    """Update user profile"""
    try:
        result = await users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": user_data}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {
            "success": True,
            "message": "User profile updated successfully",
            "user_id": user_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{user_id}/quizzes")
async def get_user_quizzes(user_id: str):
    """Get all quizzes created by a user"""
    try:
        # For demo purposes, we'll store creator_id in quizzes
        cursor = collection.find({"creator_id": user_id})
        quizzes = await cursor.to_list(length=None)
        
        quiz_items = [
            {
                "id": str(quiz["_id"]),
                "title": quiz.get("title", ""),
                "description": quiz.get("description", ""),
                "coverImagePath": quiz.get("coverImagePath", ""),
                "category": quiz.get("category", ""),
                "language": quiz.get("language", ""),
                "questionCount": len(quiz.get("questions", [])),
                "createdAt": quiz.get("createdAt", "")
            }
            for quiz in quizzes
        ]
        
        return {
            "success": True,
            "user_id": user_id,
            "count": len(quiz_items),
            "quizzes": quiz_items
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
