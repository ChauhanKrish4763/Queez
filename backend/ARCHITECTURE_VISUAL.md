# FastAPI Backend Architecture - Visual Guide

## 🏗️ Architecture Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Request                          │
│              (Flutter App / Postman / etc.)                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    main.py (Legacy)                         │
│                         │                                   │
│                         ├──► Redirects to app/main.py       │
└─────────────────────────┼───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   app/main.py                               │
│  ┌───────────────────────────────────────────────────┐     │
│  │  FastAPI App Instance                             │     │
│  │  • CORS Middleware                                │     │
│  │  • Configuration from core/config.py              │     │
│  └───────────────────────────────────────────────────┘     │
│                         │                                   │
│         Includes All Route Modules ▼                        │
└─────────────────────────┼───────────────────────────────────┘
                          │
           ┌──────────────┼──────────────┐
           │              │              │
           ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│   Quizzes    │ │   Sessions   │ │  Analytics   │
│   Router     │ │   Router     │ │   Router     │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│    Users     │ │   Reviews    │ │   Results    │
│   Router     │ │   Router     │ │   Router     │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐
│ Leaderboard  │ │  Categories  │
│   Router     │ │   Router     │
└──────┬───────┘ └──────┬───────┘
       │                │
       └────────┬───────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Models     │  │   Database   │  │   Helpers    │     │
│  │  (Pydantic)  │  │  (MongoDB)   │  │  (Utils)     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Module Responsibilities

### **app/main.py** (Entry Point)

```python
Creates FastAPI app
  ├─ Loads configuration
  ├─ Sets up CORS
  └─ Includes all routers
```

### **app/core/** (Foundation)

```python
config.py       → Environment variables, settings
database.py     → MongoDB connection, collection references
```

### **app/models/** (Data Schemas)

```python
quiz.py         → Quiz, Question, QuizResponse models
session.py      → Session, SessionInfo, ParticipantJoin models
```

### **app/api/routes/** (Business Logic)

```python
quizzes.py      → POST /quizzes, GET /quizzes/{id}, etc.
sessions.py     → POST /api/quiz/{id}/create-session, etc.
analytics.py    → GET /quizzes/{id}/stats, etc.
users.py        → POST /users, GET /users/{id}, etc.
reviews.py      → POST /quizzes/{id}/reviews, etc.
results.py      → POST /results, GET /results/{id}, etc.
leaderboard.py  → GET /leaderboard/{id}
categories.py   → GET /categories, /languages, /tags
```

### **app/utils/** (Shared Code)

```python
helpers.py      → generate_session_code(), etc.
```

## 🔄 Request Flow Example

**Creating a Quiz:**

```
1. Client → POST /quizzes
              ↓
2. main.py → Routes to quizzes.router
              ↓
3. quizzes.py → create_quiz() function
              ↓
4. Validates using Quiz model (models/quiz.py)
              ↓
5. Connects to MongoDB (core/database.py)
              ↓
6. Inserts quiz into collection
              ↓
7. Returns QuizResponse to client
```

## 🎯 Route Organization

### Quiz Management

- `/quizzes` - Create, update, delete quizzes
- `/quizzes/library/{user_id}` - User's quiz library
- `/quizzes/search` - Search quizzes
- `/quizzes/category/{category}` - Filter by category
- `/quizzes/{quiz_id}` - Get specific quiz

### Session Management

- `/api/quiz/{id}/create-session` - Create session
- `/api/session/{code}` - Get session info
- `/api/session/{code}/join` - Join session
- `/api/session/{code}/start` - Start quiz
- `/api/session/{code}/end` - End session

### Analytics & Stats

- `/quizzes/{id}/stats` - Quiz statistics
- `/quizzes/{id}/attempt` - Record attempt
- `/quizzes/{id}/attempts` - Get all attempts
- `/dashboard/stats` - Overall statistics

### User Management

- `/users` - Create user
- `/users/{id}` - Get/update user
- `/users/{id}/quizzes` - User's quizzes

### Reviews & Ratings

- `/quizzes/{id}/reviews` - Add/get reviews

### Results & Leaderboard

- `/results` - Submit results
- `/results/{quiz_id}` - Get results
- `/leaderboard/{quiz_id}` - Get rankings

### Categories & Tags

- `/categories` - Get all categories
- `/languages` - Get all languages
- `/tags` - Get/create tags

## 🔧 Configuration Flow

```
.env file
   ↓
core/config.py (loads environment variables)
   ↓
core/database.py (uses config to connect)
   ↓
All route modules (import from core.database)
```

## 📦 Import Structure

```python
# In route files
from app.models.quiz import Quiz, QuizResponse
from app.core.database import collection, sessions_collection
from app.utils.helpers import generate_session_code

# In main.py
from app.core.config import APP_TITLE, CORS_ORIGINS
from app.api.routes import quizzes, sessions, analytics
```

## 🚀 Deployment Considerations

### Development

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Production

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Docker (Future)

```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app/ ./app/
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 📝 Adding New Features

### Example: Adding a new "Comments" feature

1. **Create model** (`app/models/comment.py`):

```python
from pydantic import BaseModel

class Comment(BaseModel):
    user_id: str
    quiz_id: str
    text: str
```

2. **Add collection** (`app/core/database.py`):

```python
comments_collection = db.comments
```

3. **Create routes** (`app/api/routes/comments.py`):

```python
from fastapi import APIRouter
router = APIRouter(prefix="/comments", tags=["comments"])

@router.post("")
async def create_comment(comment: Comment):
    # Implementation
```

4. **Include router** (`app/main.py`):

```python
from app.api.routes import comments
app.include_router(comments.router)
```

That's it! Clean and modular.

## ✅ Best Practices Followed

- ✅ Separation of concerns
- ✅ Single responsibility principle
- ✅ DRY (Don't Repeat Yourself)
- ✅ Explicit is better than implicit
- ✅ Flat is better than nested
- ✅ Readability counts
- ✅ Modular and scalable
- ✅ Easy to test
- ✅ Easy to maintain
- ✅ Production-ready structure
