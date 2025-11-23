from fastapi import APIRouter, HTTPException
from datetime import datetime

from app.core.database import collection, tags_collection

router = APIRouter(tags=["categories"])

@router.get("/categories")
async def get_categories():
    """Get all available categories with quiz counts"""
    try:
        # Get distinct categories from quizzes
        categories = await collection.distinct("category")
        
        category_list = []
        for category in categories:
            count = await collection.count_documents({"category": category})
            category_list.append({
                "name": category,
                "quiz_count": count
            })
        
        return {
            "success": True,
            "count": len(category_list),
            "categories": category_list
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/languages")
async def get_languages():
    """Get all available languages with quiz counts"""
    try:
        # Get distinct languages from quizzes
        languages = await collection.distinct("language")
        
        language_list = []
        for language in languages:
            count = await collection.count_documents({"language": language})
            language_list.append({
                "name": language,
                "quiz_count": count
            })
        
        return {
            "success": True,
            "count": len(language_list),
            "languages": language_list
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/tags")
async def get_tags():
    """Get all tags"""
    try:
        cursor = tags_collection.find({})
        tags = await cursor.to_list(length=None)
        
        tag_list = [
            {
                "tag_id": str(tag["_id"]),
                "name": tag.get("name", ""),
                "count": tag.get("count", 0),
                "created_at": tag.get("created_at", "")
            }
            for tag in tags
        ]
        
        return {
            "success": True,
            "count": len(tag_list),
            "tags": tag_list
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/tags")
async def create_tag(tag_data: dict):
    """Create a new tag"""
    try:
        tag = {
            "name": tag_data.get("name", ""),
            "description": tag_data.get("description", ""),
            "count": 0,
            "created_at": datetime.utcnow().isoformat()
        }
        
        result = await tags_collection.insert_one(tag)
        
        return {
            "success": True,
            "message": "Tag created successfully",
            "tag_id": str(result.inserted_id)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
