# Quiz App Backend API

A FastAPI-based backend for the Quiz App, providing endpoints for quiz management, sessions, analytics, and more.

## Architecture

**MongoDB** ↔ **FastAPI (Render)** ↔ **Flutter App**

- **Database**: MongoDB Atlas (Cloud)
- **Backend API**: FastAPI deployed on Render
- **Frontend**: Flutter mobile app

## Quick Start (Local Development)

### Prerequisites

- Python 3.11+
- MongoDB (local) or MongoDB Atlas account

### Installation

1. Install dependencies:

```bash
pip install -r requirements.txt
```

2. Create `.env` file (copy from `.env.example`):

```bash
cp .env.example .env
```

3. Update `.env` with your MongoDB connection string:

```
MONGODB_URL=mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority
MONGODB_DB_NAME=quiz_app
```

4. Run the server:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

5. Access the API:

- API: http://localhost:8000
- Swagger Docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Deployment to Render

See [RENDER_DEPLOYMENT_GUIDE.md](./RENDER_DEPLOYMENT_GUIDE.md) for detailed deployment instructions.

### Quick Deploy Steps:

1. **Set up MongoDB Atlas**

   - Create free cluster at https://cloud.mongodb.com/
   - Get connection string

2. **Deploy to Render**

   - Push code to GitHub
   - Connect repository to Render
   - Add `MONGODB_URL` environment variable
   - Deploy!

3. **Update Flutter App**
   - Copy your Render URL (e.g., `https://quiz-app-backend.onrender.com`)
   - Update `quiz_app/lib/api_config.dart`:
   ```dart
   static const String baseUrl = 'https://your-app.onrender.com';
   ```

## API Endpoints

### Core Resources

- **Quizzes**: `/quizzes/*` - Create, read, update, delete quizzes
- **Sessions**: `/sessions/*` - Manage quiz sessions
- **Results**: `/results/*` - Track quiz results
- **Analytics**: `/analytics/*` - Get quiz statistics
- **Users**: `/users/*` - User management
- **Reviews**: `/reviews/*` - Quiz reviews and ratings
- **Leaderboard**: `/leaderboard/*` - Rankings and scores
- **Categories**: `/categories/*` - Quiz categories

### Documentation

- Swagger UI: `{baseUrl}/docs`
- ReDoc: `{baseUrl}/redoc`

## Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI app initialization
│   ├── core/
│   │   └── config.py        # Configuration settings
│   ├── api/
│   │   └── routes/          # API endpoints
│   ├── models/              # Data models
│   └── utils/               # Utility functions
├── requirements.txt         # Python dependencies
├── Dockerfile              # Docker configuration
├── render.yaml             # Render deployment config
└── .env.example            # Environment variables template
```

## Environment Variables

| Variable          | Description                      | Example             |
| ----------------- | -------------------------------- | ------------------- |
| `MONGODB_URL`     | MongoDB connection string        | `mongodb+srv://...` |
| `MONGODB_DB_NAME` | Database name                    | `quiz_app`          |
| `PORT`            | Server port (auto-set by Render) | `8000`              |

## Development

### Run with auto-reload:

```bash
uvicorn app.main:app --reload
```

### Run tests:

```bash
pytest
```

### API Testing:

- Import `QuizApp_API_Collection.postman_collection.json` into Postman
- See `API_TESTING_REPORT.md` for detailed testing documentation

## Tech Stack

- **FastAPI**: Modern Python web framework
- **Motor**: Async MongoDB driver
- **Pydantic**: Data validation
- **Uvicorn**: ASGI server
- **MongoDB**: NoSQL database

## Support

For issues or questions, check the deployment guide or API documentation.
