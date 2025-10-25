from pydantic import BaseModel
from typing import List, Optional, Dict

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
    creatorId: str
    originalOwner: Optional[str] = None  # For quizzes added from other users
    sharedMode: Optional[str] = None  # Mode used when quiz was shared (share, self_paced, timed_individual, live_multiplayer)
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
    originalOwner: Optional[str] = None
    originalOwnerUsername: Optional[str] = None  # Fetched from Firestore
    sharedMode: Optional[str] = None  # Mode used when quiz was shared


class QuizLibraryResponse(BaseModel):
    success: bool
    data: List[QuizLibraryItem]
    count: int
