from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from typing import List, Optional, Dict
from datetime import datetime, timedelta
from bson import ObjectId
import math

app = FastAPI()

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB connection
MONGODB_URL = "mongodb+srv://<username>:<password>@cluster0.tr8mdna.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
client = AsyncIOMotorClient(MONGODB_URL)
db = client.quiz_app
collection = db.quizzes

# Models
class Question(BaseModel):
    id: str
    questionText: str
    type: str
    options: List[str]
    correctAnswerIndex: Optional[int] = None
    correctAnswerIndices: Optional[List[int]] = None
    dragItems: Optional[List[str]] = None
    dropTargets: Optional[List[str]] = None
    correctMatches: Optional[Dict[str, str]] = None

class Quiz(BaseModel):
    id: Optional[str] = None
    title: str
    description: str
    language: str
    category: str
    coverImagePath: Optional[str] = None
    questions: List[Question]
    createdAt: Optional[datetime] = None  # still needed for creation, but won't be returned

class QuizResponse(BaseModel):
    id: str
    message: str

class QuizLibraryItem(BaseModel):
    id: str
    title: str
    coverImagePath: Optional[str] = None

class QuizLibraryResponse(BaseModel):
    success: bool
    data: List[QuizLibraryItem]
    count: int

@app.post("/quizzes", response_model=QuizResponse)
async def create_quiz(quiz: Quiz):
    try:
        quiz_dict = quiz.dict()
        quiz_dict.pop("id", None)

        # Ensure createdAt is present to keep MongoDB consistent
        quiz_dict["createdAt"] = quiz_dict.get("createdAt", datetime.utcnow())

        result = await collection.insert_one(quiz_dict)
        return QuizResponse(
            id=str(result.inserted_id),
            message="Quiz created successfully"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/quizzes/library", response_model=QuizLibraryResponse)
async def get_quiz_library():
    try:
        cursor = collection.find(
            {},
            {
                "title": 1,
                "coverImagePath": 1,
                "_id": 1
            }
        ).sort("createdAt", -1)

        quizzes = await cursor.to_list(length=None)

        formatted = [
            QuizLibraryItem(
                id=str(quiz["_id"]),
                title=quiz.get("title", "Untitled Quiz"),
                coverImagePath=quiz.get("coverImagePath")
            )
            for quiz in quizzes
        ]

        return QuizLibraryResponse(
            success=True,
            data=formatted,
            count=len(formatted)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/")
async def root():
    return {"message": "Quiz API is running!"}

# uvicorn main:app --host 0.0.0.0 --port 8000 --reload