import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# MongoDB configuration
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
MONGODB_DB_NAME = os.getenv("MONGODB_DB_NAME", "quiz_app")

# App configuration
APP_TITLE = "Quiz App API"
APP_VERSION = "1.0"
APP_DESCRIPTION = "FastAPI Quiz Application Backend"

# CORS origins
CORS_ORIGINS = ["*"]
CORS_CREDENTIALS = True
CORS_METHODS = ["*"]
CORS_HEADERS = ["*"]
