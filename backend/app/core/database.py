from motor.motor_asyncio import AsyncIOMotorClient
from app.core.config import MONGODB_URL, MONGODB_DB_NAME

# MongoDB client and database
client = AsyncIOMotorClient(MONGODB_URL)
db = client[MONGODB_DB_NAME]

# Collections
collection = db.quizzes
sessions_collection = db.quiz_sessions
session_participants_collection = db.session_participants
attempts_collection = db.quiz_attempts
users_collection = db.users
reviews_collection = db.quiz_reviews
results_collection = db.quiz_results
tags_collection = db.tags
