from pydantic import BaseModel
from typing import Optional, List, Dict
from datetime import datetime

# Existing models
class SessionCreate(BaseModel):
    quiz_id: str
    host_id: str
    mode: str  # "live_multiplayer", "self_paced", "timed_individual"

class SessionResponse(BaseModel):
    success: bool
    session_code: str
    expires_in: int  # seconds
    expires_at: str

class SessionInfo(BaseModel):
    success: bool
    session_code: str
    quiz_id: str
    host_id: str
    mode: str
    participant_count: int
    is_active: bool
    is_started: bool
    created_at: str
    expires_at: str

class ParticipantJoin(BaseModel):
    user_id: str
    username: str

# New models for live multiplayer
class LiveParticipant(BaseModel):
    user_id: str
    username: str
    avatar_url: Optional[str] = None
    score: int = 0
    current_question_answered: bool = False
    is_connected: bool = True
    joined_at: str

class LiveSessionState(BaseModel):
    session_code: str
    quiz_id: str
    host_id: str
    status: str  # "waiting", "in_progress", "completed"
    current_question_index: int = -1
    total_questions: int
    participants: List[LiveParticipant]
    started_at: Optional[str] = None
    completed_at: Optional[str] = None

class AnswerSubmission(BaseModel):
    session_code: str
    question_index: int
    answer_index: int  # For single choice
    answer_indices: Optional[List[int]] = None  # For multiple choice
    time_taken: float  # seconds

class QuestionResult(BaseModel):
    question_index: int
    correct_answer_index: Optional[int] = None
    correct_answer_indices: Optional[List[int]] = None
    participant_answers: Dict[str, int]  # user_id -> answer_index
    participant_times: Dict[str, float]  # user_id -> time_taken
