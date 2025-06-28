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
MONGODB_URL = "mongodb+srv://USERNAME:PASSWORD@cluster0.tr8mdna.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
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
    createdAt: Optional[str] = None  # string instead of datetime


class QuizResponse(BaseModel):
    id: str
    message: str

class QuizLibraryItem(BaseModel):
    id: str
    title: str
    description: str
    coverImagePath: Optional[str] = None
    createdAt: Optional[str] = None
    questionCount: int
    language: str
    category: str


class QuizLibraryResponse(BaseModel):
    success: bool
    data: List[QuizLibraryItem]
    count: int

@app.post("/quizzes", response_model=QuizResponse)
async def create_quiz(quiz: Quiz):
    try:
        quiz_dict = quiz.dict()
        quiz_dict.pop("id", None)

        # Format createdAt as "Month, Year"
        now = datetime.utcnow()
        quiz_dict["createdAt"] = now.strftime("%B, %Y")

        # Set default cover image based on category if not provided
        if not quiz_dict.get("coverImagePath"):
            category = quiz_dict.get("category", "others").lower()
            if category == "language learning":
                quiz_dict["coverImagePath"] = "https://img.freepik.com/free-vector/notes-concept-illustration_114360-839.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"
            elif category == "science and technology":
                quiz_dict["coverImagePath"] = "https://img.freepik.com/free-vector/coding-concept-illustration_114360-1155.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"
            elif category == "law":
                quiz_dict["coverImagePath"] = "http://img.freepik.com/free-vector/law-firm-concept-illustration_114360-8626.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"
            else:
                quiz_dict["coverImagePath"] = "https://img.freepik.com/free-vector/student-asking-teacher-concept-illustration_114360-19831.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"

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
                "description": 1,
                "coverImagePath": 1,
                "createdAt": 1,
                "questions": 1,  # needed temporarily to count length
                "language": 1,
                "category": 1,
                "_id": 1
            }
        ).sort("createdAt", -1)

        quizzes = await cursor.to_list(length=None)

        fallback_image = "https://img.freepik.com/free-vector/student-asking-teacher-concept-illustration_114360-19831.jpg?ga=GA1.1.377073698.1750732876&semt=ais_items_boosted&w=740"

        quiz_items = [
            QuizLibraryItem(
                id=str(quiz["_id"]),
                title=quiz.get("title", "Untitled Quiz"),
                description=quiz.get("description", ""),
                coverImagePath=quiz.get("coverImagePath") or fallback_image,
                createdAt=quiz.get("createdAt", ""),
                questionCount=len(quiz.get("questions", [])),
                language=quiz.get("language", ""),
                category=quiz.get("category", ""),
            )
            for quiz in quizzes
        ]

        return QuizLibraryResponse(
            success=True,
            data=quiz_items,
            count=len(quiz_items)
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/quizzes/{quiz_id}", response_model=Quiz)
async def get_quiz_by_id(quiz_id: str):
    try:
        quiz = await collection.find_one({"_id": ObjectId(quiz_id)})

        if not quiz:
            raise HTTPException(status_code=404, detail="Quiz not found")

        # Convert MongoDB _id to string
        quiz["id"] = str(quiz["_id"])
        quiz.pop("_id", None)

        return quiz
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/")

async def root():
    return {"message": "Quiz API is running!"}

# uvicorn main:app --host 0.0.0.0 --port 8000 --reload