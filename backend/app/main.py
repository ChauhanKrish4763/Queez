from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import (
    APP_TITLE,
    APP_VERSION,
    APP_DESCRIPTION,
    CORS_ORIGINS,
    CORS_CREDENTIALS,
    CORS_METHODS,
    CORS_HEADERS
)
from app.api.routes import (
    quizzes,
    flashcards,
    library,
    sessions,
    analytics,
    users,
    reviews,
    results,
    leaderboard,
    categories
)

app = FastAPI(
    title=APP_TITLE,
    version=APP_VERSION,
    description=APP_DESCRIPTION
)

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=CORS_CREDENTIALS,
    allow_methods=CORS_METHODS,
    allow_headers=CORS_HEADERS,
)

# Include routers
app.include_router(quizzes.router)
app.include_router(flashcards.router)
app.include_router(library.router)
app.include_router(sessions.router)
app.include_router(analytics.router)
app.include_router(users.router)
app.include_router(reviews.router)
app.include_router(results.router)
app.include_router(leaderboard.router)
app.include_router(categories.router)

@app.get("/")
async def root():
    return {
        "success": True,
        "message": "Quiz API is running!",
        "version": APP_VERSION,
        "endpoints": "/docs for API documentation"
    }

# Local development:
# uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
