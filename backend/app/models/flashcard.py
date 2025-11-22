from pydantic import BaseModel
from typing import List, Optional

class Card(BaseModel):
    id: Optional[str] = None
    front: str
    back: str

class FlashcardSet(BaseModel):
    id: Optional[str] = None
    title: str
    description: str
    category: str
    coverImagePath: Optional[str] = None
    creatorId: str
    originalOwner: Optional[str] = None
    cards: List[Card]
    createdAt: Optional[str] = None

class FlashcardSetResponse(BaseModel):
    id: str
    message: str

class FlashcardLibraryItem(BaseModel):
    id: str
    title: str
    description: str
    coverImagePath: Optional[str] = None
    createdAt: Optional[str] = None
    cardCount: int
    category: str
    originalOwner: Optional[str] = None
    originalOwnerUsername: Optional[str] = None

class FlashcardLibraryResponse(BaseModel):
    success: bool
    data: List[FlashcardLibraryItem]
    count: int
