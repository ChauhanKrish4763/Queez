import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# MongoDB configuration
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
MONGODB_DB_NAME = os.getenv("MONGODB_DB_NAME", "quiz_app")

# Redis configuration
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")
REDIS_MAX_CONNECTIONS = int(os.getenv("REDIS_MAX_CONNECTIONS", "50"))

# WebSocket configuration
WEBSOCKET_PING_INTERVAL = int(os.getenv("WEBSOCKET_PING_INTERVAL", "30"))
RECONNECTION_TIMEOUT = int(os.getenv("RECONNECTION_TIMEOUT", "60"))

# Game configuration
ANSWER_REVEAL_SECONDS = int(os.getenv("ANSWER_REVEAL_SECONDS", "5"))
QUESTION_TIME_SECONDS = int(os.getenv("QUESTION_TIME_SECONDS", "30"))
SESSION_EXPIRY_HOURS = int(os.getenv("SESSION_EXPIRY_HOURS", "24"))
MAX_PARTICIPANTS_PER_SESSION = int(os.getenv("MAX_PARTICIPANTS_PER_SESSION", "50"))

# App configuration
APP_TITLE = "Quiz App API"
APP_VERSION = "1.0"
APP_DESCRIPTION = "FastAPI Quiz Application Backend"

# CORS origins
# Note: When allow_credentials=True, you cannot use wildcard "*" for origins
# You must explicitly list allowed origins
CORS_ORIGINS = [
    "http://localhost:8000",
    "http://10.0.2.2:8000",  # Android emulator
    "http://127.0.0.1:8000",
]
CORS_CREDENTIALS = True
CORS_METHODS = ["*"]
CORS_HEADERS = ["*"]
