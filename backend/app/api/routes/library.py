from fastapi import APIRouter, HTTPException
from typing import List, Union
from app.core.database import db
from pydantic import BaseModel

router = APIRouter(prefix="/library", tags=["library"])

# Get collections
quiz_collection = db["quizzes"]
flashcard_collection = db["flashcard_sets"]

class LibraryItem(BaseModel):
    id: str
    type: str  # "quiz" or "flashcard"
    title: str
    description: str
    coverImagePath: str
    createdAt: str
    itemCount: int  # questionCount for quizzes, cardCount for flashcards
    category: str
    language: str = ""  # Only for quizzes
    originalOwner: str | None = None
    originalOwnerUsername: str | None = None
    sharedMode: str | None = None  # Only for quizzes

class UnifiedLibraryResponse(BaseModel):
    success: bool
    data: List[LibraryItem]
    count: int

@router.get("/{user_id}", response_model=UnifiedLibraryResponse, summary="Get all quizzes and flashcards for a user")
async def get_unified_library(user_id: str):
    try:
        fallback_image = "https://img.freepik.com/free-vector/student-asking-teacher-concept-illustration_114360-19831.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"
        
        # Fetch quizzes
        quiz_cursor = quiz_collection.find(
            {"creatorId": user_id},
            {
                "title": 1,
                "description": 1,
                "coverImagePath": 1,
                "createdAt": 1,
                "questions": 1,
                "language": 1,
                "category": 1,
                "_id": 1,
                "originalOwner": 1,
                "sharedMode": 1
            }
        )
        quizzes = await quiz_cursor.to_list(length=None)
        
        # Fetch flashcards
        flashcard_cursor = flashcard_collection.find(
            {"creatorId": user_id},
            {
                "title": 1,
                "description": 1,
                "coverImagePath": 1,
                "createdAt": 1,
                "cards": 1,
                "category": 1,
                "_id": 1,
                "originalOwner": 1
            }
        )
        flashcards = await flashcard_cursor.to_list(length=None)
        
        # Convert quizzes to LibraryItem
        library_items = []
        for quiz in quizzes:
            library_items.append(LibraryItem(
                id=str(quiz["_id"]),
                type="quiz",
                title=quiz.get("title", "Untitled Quiz"),
                description=quiz.get("description", ""),
                coverImagePath=quiz.get("coverImagePath") or fallback_image,
                createdAt=quiz.get("createdAt", ""),
                itemCount=len(quiz.get("questions", [])),
                language=quiz.get("language", ""),
                category=quiz.get("category", ""),
                originalOwner=quiz.get("originalOwner"),
                originalOwnerUsername=None,
                sharedMode=quiz.get("sharedMode")
            ))
        
        # Convert flashcards to LibraryItem
        for flashcard_set in flashcards:
            library_items.append(LibraryItem(
                id=str(flashcard_set["_id"]),
                type="flashcard",
                title=flashcard_set.get("title", "Untitled Flashcard Set"),
                description=flashcard_set.get("description", ""),
                coverImagePath=flashcard_set.get("coverImagePath") or fallback_image,
                createdAt=flashcard_set.get("createdAt", ""),
                itemCount=len(flashcard_set.get("cards", [])),
                category=flashcard_set.get("category", ""),
                originalOwner=flashcard_set.get("originalOwner"),
                originalOwnerUsername=None
            ))
        
        # Sort by createdAt (most recent first)
        # Note: This is a simple string sort. For better sorting, parse dates
        library_items.sort(key=lambda x: x.createdAt, reverse=True)
        
        return UnifiedLibraryResponse(
            success=True,
            data=library_items,
            count=len(library_items)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
