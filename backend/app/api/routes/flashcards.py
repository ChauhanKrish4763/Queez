from fastapi import APIRouter, HTTPException, Query
from typing import List
from datetime import datetime
from bson import ObjectId

from app.models.flashcard import FlashcardSet, FlashcardSetResponse, FlashcardLibraryItem, FlashcardLibraryResponse
from app.core.database import db

router = APIRouter(prefix="/flashcards", tags=["flashcards"])

# Get the flashcard_sets collection
flashcard_collection = db["flashcard_sets"]

@router.post("", response_model=FlashcardSetResponse, summary="Create a new flashcard set")
async def create_flashcard_set(flashcard_set: FlashcardSet):
    try:
        # Validate required fields
        if not flashcard_set.title or not flashcard_set.title.strip():
            raise HTTPException(status_code=400, detail="Title cannot be empty")
        
        if not flashcard_set.description or not flashcard_set.description.strip():
            raise HTTPException(status_code=400, detail="Description cannot be empty")
        
        if not flashcard_set.category or not flashcard_set.category.strip():
            raise HTTPException(status_code=400, detail="Category cannot be empty")
        
        if not flashcard_set.cards or len(flashcard_set.cards) == 0:
            raise HTTPException(status_code=400, detail="Flashcard set must have at least one card")
        
        if not flashcard_set.creatorId or not flashcard_set.creatorId.strip():
            raise HTTPException(status_code=400, detail="creatorId is required")
        
        flashcard_dict = flashcard_set.dict()
        flashcard_dict.pop("id", None)

        # Format createdAt as "Month, Year"
        now = datetime.utcnow()
        flashcard_dict["createdAt"] = now.strftime("%B, %Y")

        # Set originalOwner to creatorId if not provided
        if not flashcard_dict.get("originalOwner"):
            flashcard_dict["originalOwner"] = flashcard_dict["creatorId"]

        # Set default cover image based on category if not provided
        if not flashcard_dict.get("coverImagePath"):
            category = flashcard_dict.get("category", "others").lower()
            if category == "language learning":
                flashcard_dict["coverImagePath"] = "https://img.freepik.com/free-vector/notes-concept-illustration_114360-839.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"
            elif category == "science and technology":
                flashcard_dict["coverImagePath"] = "https://img.freepik.com/free-vector/coding-concept-illustration_114360-1155.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"
            elif category == "law":
                flashcard_dict["coverImagePath"] = "http://img.freepik.com/free-vector/law-firm-concept-illustration_114360-8626.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"
            else:
                flashcard_dict["coverImagePath"] = "https://img.freepik.com/free-vector/student-asking-teacher-concept-illustration_114360-19831.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"

        result = await flashcard_collection.insert_one(flashcard_dict)
        return FlashcardSetResponse(
            id=str(result.inserted_id),
            message="Flashcard set created successfully"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/library/{user_id}", response_model=FlashcardLibraryResponse, summary="Get all flashcard sets created by a user")
async def get_flashcard_library_by_user(user_id: str):
    try:
        cursor = flashcard_collection.find(
            {"creatorId": user_id},
            {
                "title": 1,
                "description": 1,
                "coverImagePath": 1,
                "createdAt": 1,
                "cards": 1,
                "category": 1,
                "_id": 1,
                "creatorId": 1,
                "originalOwner": 1
            }
        ).sort("createdAt", -1)

        flashcard_sets = await cursor.to_list(length=None)

        fallback_image = "https://img.freepik.com/free-vector/student-asking-teacher-concept-illustration_114360-19831.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"

        flashcard_items = [
            FlashcardLibraryItem(
                id=str(fs["_id"]),
                title=fs.get("title", "Untitled Flashcard Set"),
                description=fs.get("description", ""),
                coverImagePath=fs.get("coverImagePath") or fallback_image,
                createdAt=fs.get("createdAt", ""),
                cardCount=len(fs.get("cards", [])),
                category=fs.get("category", ""),
                originalOwner=fs.get("originalOwner"),
                originalOwnerUsername=None
            )
            for fs in flashcard_sets
        ]

        return FlashcardLibraryResponse(
            success=True,
            data=flashcard_items,
            count=len(flashcard_items)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{flashcard_set_id}", response_model=FlashcardSet, summary="Get a specific flashcard set with all cards")
async def get_flashcard_set(flashcard_set_id: str, user_id: str = Query(...)):
    try:
        if not ObjectId.is_valid(flashcard_set_id):
            raise HTTPException(status_code=400, detail="Invalid flashcard set ID")

        flashcard_set = await flashcard_collection.find_one(
            {"_id": ObjectId(flashcard_set_id), "creatorId": user_id}
        )

        if not flashcard_set:
            raise HTTPException(status_code=404, detail="Flashcard set not found")

        flashcard_set["id"] = str(flashcard_set.pop("_id"))
        return FlashcardSet(**flashcard_set)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{flashcard_set_id}", summary="Delete a flashcard set")
async def delete_flashcard_set(flashcard_set_id: str):
    try:
        if not ObjectId.is_valid(flashcard_set_id):
            raise HTTPException(status_code=400, detail="Invalid flashcard set ID")

        result = await flashcard_collection.delete_one({"_id": ObjectId(flashcard_set_id)})

        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Flashcard set not found")

        return {"success": True, "message": "Flashcard set deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/add-to-library", summary="Add a flashcard set to user's library")
async def add_flashcard_to_library(data: dict):
    try:
        flashcard_set_id = data.get("flashcard_set_id")
        user_id = data.get("user_id")

        if not flashcard_set_id or not user_id:
            raise HTTPException(status_code=400, detail="flashcard_set_id and user_id are required")

        if not ObjectId.is_valid(flashcard_set_id):
            raise HTTPException(status_code=400, detail="Invalid flashcard set ID")

        # Get the original flashcard set
        original_set = await flashcard_collection.find_one({"_id": ObjectId(flashcard_set_id)})

        if not original_set:
            raise HTTPException(status_code=404, detail="Flashcard set not found")

        # Create a copy for the new user
        new_set = original_set.copy()
        new_set.pop("_id")
        new_set["creatorId"] = user_id
        new_set["originalOwner"] = original_set.get("creatorId")

        result = await flashcard_collection.insert_one(new_set)

        return {
            "success": True,
            "message": "Flashcard set added to library",
            "id": str(result.inserted_id)
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
