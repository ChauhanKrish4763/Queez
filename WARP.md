# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Queez is an interactive learning and assessment platform with a Flutter mobile app frontend and FastAPI backend. The platform supports quiz creation, flashcards, polls, surveys, and classroom management features.

**Tech Stack:**
- Frontend: Flutter/Dart (cross-platform mobile)
- Backend: FastAPI (Python 3.8+)
- Database: MongoDB Atlas (quiz data) + Cloud Firestore (user profiles)
- Authentication: Firebase Auth
- State Management: Riverpod

## Development Commands

### Backend (FastAPI)

```bash
# Navigate to backend directory
cd backend

# Run development server (recommended)
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Alternative: Run via legacy entry point
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# Run automated API tests
python test_api_automated.py

# Expose local server (using localtunnel)
lt --port 8000 --subdomain quizapp2024
```

**Environment Setup:**
- Create `.env` file in backend directory with MongoDB connection string
- See `.env.example` for template (if available)

### Frontend (Flutter)

```bash
# Navigate to Flutter app
cd quiz_app

# Get dependencies
flutter pub get

# Generate Riverpod code (after modifying providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous code generation
flutter pub run build_runner watch

# Run on connected device/emulator
flutter run

# Build for specific platforms
flutter build apk           # Android
flutter build appbundle     # Android App Bundle
flutter build ios           # iOS (macOS only)

# Run tests
flutter test

# Check for outdated dependencies
flutter pub outdated
```

**Linting:**
```bash
# Run Flutter analyzer
flutter analyze

# Run custom lint checks (Riverpod lint)
flutter pub run custom_lint
```

## Architecture

### Backend Structure (Modular FastAPI)

```
backend/
├── app/
│   ├── main.py              # Application entry point
│   ├── api/
│   │   └── routes/          # Route modules
│   │       ├── quizzes.py   # Quiz CRUD operations
│   │       ├── sessions.py  # Live quiz sessions
│   │       ├── analytics.py # Statistics endpoints
│   │       ├── users.py     # User management
│   │       ├── reviews.py   # Quiz reviews/ratings
│   │       ├── results.py   # Quiz results
│   │       ├── leaderboard.py
│   │       └── categories.py
│   ├── core/                # Core configuration
│   ├── models/              # Pydantic models
│   └── utils/               # Utility functions
├── main.py                  # Legacy entry point (redirects to app.main)
├── requirements.txt
└── test_api_automated.py
```

**Key Backend Patterns:**
- All routes use async/await for non-blocking I/O
- Motor library for async MongoDB operations
- Pydantic models for request/response validation
- CORS enabled for all origins (configured in `core/config.py`)
- RESTful design with proper HTTP status codes

### Frontend Structure (Flutter)

```
quiz_app/lib/
├── main.dart                     # App entry point
├── CreateSection/                # Quiz creation features
│   ├── models/                   # Quiz & Question models
│   ├── screens/                  # Quiz creation UI
│   ├── services/                 # Quiz API & cache
│   └── widgets/                  # Reusable components
├── LibrarySection/               # Quiz library/browse
│   ├── screens/
│   ├── services/
│   └── widgets/
├── ProfilePage/                  # User profile display
├── ProfileSetup/                 # 4-step onboarding
│   ├── screens/
│   └── widgets/
├── providers/                    # Riverpod state providers
├── screens/                      # Main app screens
│   ├── dashboard.dart
│   └── login_page.dart
├── models/                       # Shared data models
├── utils/                        # Utilities
│   ├── animations/               # Page transitions
│   ├── color.dart                # Brand colors
│   └── routes.dart               # Route definitions
└── widgets/                      # Global components
    ├── navbar/                   # Bottom navigation
    └── appbar/
```

**Key Frontend Patterns:**
- Riverpod for state management (migration from StatefulWidget)
- Feature-based folder structure (CreateSection, LibrarySection, etc.)
- SharedPreferences for local persistence (session, cache)
- Firebase Auth for authentication
- Firestore for user profiles
- HTTP package for backend API calls

## Database Schema

### MongoDB Collections

**quizzes:**
```javascript
{
  _id: ObjectId,
  title: String,
  description: String,
  language: String,
  category: String,
  coverImagePath: String,
  createdAt: String,           // "Month, Year" format
  createdBy: String,            // User UID (planned)
  questions: [
    {
      id: String,
      questionText: String,
      type: String,              // "singleMcq", "multiMcq", "trueFalse", "dragAndDrop"
      options: [String],
      correctAnswerIndex: Number,
      correctAnswerIndices: [Number],
      dragItems: [String],
      dropTargets: [String],
      correctMatches: Object
    }
  ]
}
```

**quiz_attempts, quiz_reviews, quiz_results** collections exist (see SRS_DOCUMENT.md for schemas)

### Firestore Collections

**users:**
- Stored in Cloud Firestore
- Contains: uid, name, role, age, dateOfBirth, subjectArea, experienceLevel, interests, profileSetupCompleted

## Important Implementation Details

### Quiz Validation Rules
- Title and description cannot be empty or whitespace
- Language and category must be selected
- At least 1 complete question required
- Backend returns HTTP 400 with specific error messages for validation failures

### Question Types
1. **Single Choice MCQ**: One correct answer (correctAnswerIndex)
2. **Multiple Choice MCQ**: Multiple correct answers (correctAnswerIndices array)
3. **True/False**: Fixed options ["True", "False"], correctAnswerIndex 0 or 1
4. **Drag and Drop**: Match dragItems to dropTargets using correctMatches map

### Authentication Flow
1. Firebase email/password authentication
2. 4-step profile setup for new users:
   - Welcome screen
   - Role selection (Student/Educator/Professional)
   - Basic info (name, age, DOB)
   - Preferences (subject area, experience level, interests)
3. Profile stored in Firestore
4. Session persistence with SharedPreferences

### Known Issues (TODO.txt)
- Profile setup UI not showing for new accounts on first load (requires hot restart)
- Library section doesn't auto-fetch quizzes on app start (requires hot restart)
- Search bar clear button (X) doesn't work in library section
- Profile images not yet implemented (image picker needed)

## Development Workflow

### Adding New Features

**Backend:**
1. Create route module in `app/api/routes/`
2. Define Pydantic models in `app/models/`
3. Add router to `app/main.py`
4. Update tests in `test_api_automated.py`

**Frontend:**
1. Create feature folder (e.g., `NewFeatureSection/`)
2. Add models, screens, services, widgets
3. Create Riverpod providers in `providers/`
4. Update navigation in `utils/routes.dart`
5. Test on both Android and iOS

### State Management Migration
- Currently transitioning from `StatefulWidget` to Riverpod
- Use `riverpod_generator` for type-safe providers
- Run code generation after creating annotated providers

### API Integration
- Base URL stored in service files
- Use `http` package for API calls
- Handle loading states, errors, and empty states
- Cache quizzes locally for offline draft saving

## Testing

**Backend:**
- Automated tests in `test_api_automated.py`
- Postman collections available for manual testing
- Test all endpoints before committing

**Frontend:**
- No comprehensive test suite yet (planned)
- Manual testing on Android/iOS required
- Test authentication flow thoroughly
- Verify Firebase configuration

## Firebase Configuration

**Required Files:**
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)
- These files are gitignored for security

**Firebase Services Used:**
- Firebase Auth (email/password)
- Cloud Firestore (user profiles)
- Firebase Storage (future: image uploads)

## Deployment

**Backend:**
- FastAPI app deployable to any ASGI server
- MongoDB Atlas connection required (connection string in .env)
- CORS configured for all origins (adjust for production)

**Frontend:**
- Build APK/App Bundle for Android
- Build IPA for iOS (requires macOS + Xcode)
- Update Firebase config for each environment

## Future Roadmap

See `SRS_DOCUMENT.md` and `TECHNICAL_FEATURES.md` for comprehensive feature roadmap including:
- Quiz attempt/taking system (high priority)
- Classroom management
- Course platform
- Flashcards, polls, surveys
- AI-powered quiz generation
- Live quiz sessions (Kahoot-style)
- Async quiz sharing (Google Forms-style)
- Analytics and leaderboards
- Premium features (Quiz Duels)

## Common Patterns

### Making Backend Changes
```bash
cd backend
# Edit files in app/
uvicorn app.main:app --reload  # Auto-reloads on changes
```

### Making Frontend Changes
```bash
cd quiz_app
# Edit files in lib/
flutter run  # Hot reload with 'r', hot restart with 'R'
```

### Adding a New Provider (Riverpod)
```dart
// In providers/my_provider.dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() => MyState.initial();
  
  void updateState() { /* ... */ }
}
```
Then run: `flutter pub run build_runner build --delete-conflicting-outputs`

### Creating a New API Endpoint
```python
# In app/api/routes/my_route.py
from fastapi import APIRouter
router = APIRouter(prefix="/api/v1", tags=["my_feature"])

@router.get("/my-endpoint")
async def my_endpoint():
    return {"success": True, "data": []}
```
Add to `app/main.py`: `app.include_router(my_route.router)`

## Code Style

**Python:**
- Follow PEP 8
- Use async/await for all database operations
- Type hints for function parameters and returns

**Dart/Flutter:**
- Follow official Dart style guide
- Use `flutter format` before committing
- Prefer Riverpod providers over StatefulWidget
- Use const constructors where possible

## Environment Variables

**Backend (.env):**
```
MONGODB_URL=mongodb+srv://...
```

**Important:** Never commit `.env` files or Firebase config files
