from pydantic import BaseModel

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
