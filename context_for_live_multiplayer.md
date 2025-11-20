# Context for Live Multiplayer Debugging

This document provides a comprehensive list of files and context needed to debug and fix live multiplayer issues in the Queez quiz application.

---

## 🎯 Overview

The Queez app has a **live multiplayer quiz system** where:
- A host creates a session with a unique 6-character code
- Players join using the session code
- All players see questions simultaneously
- Real-time scoring and leaderboard updates
- WebSocket-based communication between Flutter frontend and FastAPI backend

---

## 📋 Known Issues & Previous Fixes

### Previous WebSocket 403 Error (FIXED)
- **Issue**: WebSocket connections failing with HTTP 403
- **Root Cause**: Invalid CORS configuration (`CORS_ORIGINS = ["*"]` with `CORS_CREDENTIALS = True`)
- **Fix**: Updated CORS to use explicit origins instead of wildcard
- **Reference**: See `WEBSOCKET_FIX.md` for details

### Current Status
- Backend: All 5 tests passing ✅
- Frontend: No Flutter analysis issues ✅
- Implementation: 100% complete per `tasks.md`

---

## 🔧 Backend Files (FastAPI + Python)

### Core Application Files

1. **`backend/app/main.py`**
   - Main FastAPI application entry point
   - CORS middleware configuration
   - Router registration (including WebSocket router)
   - **Why needed**: Shows overall app structure and middleware setup

2. **`backend/app/core/config.py`**
   - Environment configuration
   - CORS settings (CORS_ORIGINS, CORS_CREDENTIALS, CORS_METHODS, CORS_HEADERS)
   - Database connection strings (MongoDB, Redis)
   - **Why needed**: Critical for CORS and connection issues

3. **`backend/.env`**
   - Environment variables
   - Database URLs
   - CORS origins configuration
   - **Why needed**: Actual runtime configuration values

### WebSocket & Session Management

4. **`backend/app/api/routes/websocket.py`**
   - WebSocket endpoint (`/ws/{session_code}`)
   - Message routing (join, submit_answer, start_quiz, end_quiz, ping)
   - Connection handling and cleanup
   - **Why needed**: Main WebSocket logic and message handling

5. **`backend/app/services/websocket_manager.py`**
   - WebSocket connection management
   - Message broadcasting
   - Connection state tracking
   - **Why needed**: Core WebSocket service layer

6. **`backend/app/services/connection_manager.py`**
   - Connection lifecycle management
   - Active connection tracking
   - Disconnect handling
   - **Why needed**: Manages WebSocket connections

7. **`backend/app/services/session_manager.py`**
   - Session creation and validation
   - Participant management
   - Session state management (Redis)
   - Session code generation
   - **Why needed**: Handles session logic and Redis operations

8. **`backend/app/services/game_controller.py`**
   - Quiz gameplay logic
   - Question management
   - Answer validation
   - Score calculation
   - Timer tracking
   - **Why needed**: Core game mechanics

9. **`backend/app/services/leaderboard_manager.py`**
   - Real-time leaderboard updates
   - Score tracking (Redis Sorted Sets)
   - Ranking calculations
   - **Why needed**: Leaderboard functionality

### Data Models

10. **`backend/app/models/session.py`**
    - Session data models
    - Participant models
    - Session state schemas
    - **Why needed**: Data structure definitions

11. **`backend/app/models/quiz.py`**
    - Quiz data models
    - Question models
    - Answer schemas
    - **Why needed**: Quiz data structures

### API Routes (Supporting)

12. **`backend/app/api/routes/sessions.py`**
    - REST endpoints for session management
    - Create session endpoint
    - Get session info endpoint
    - **Why needed**: Session creation and retrieval

13. **`backend/app/api/routes/quizzes.py`**
    - Quiz CRUD operations
    - Quiz retrieval for sessions
    - **Why needed**: Quiz data access

### Configuration Files

14. **`backend/requirements.txt`**
    - Python dependencies
    - FastAPI, WebSocket, Redis, MongoDB libraries
    - **Why needed**: Verify all required packages are installed

---

## 📱 Frontend Files (Flutter + Dart)

### Main Application

15. **`quiz_app/lib/main.dart`**
    - App entry point
    - Provider setup
    - Theme configuration
    - **Why needed**: App initialization and provider configuration

### WebSocket Service

16. **`quiz_app/lib/services/websocket_service.dart`**
    - WebSocket client implementation
    - Connection management
    - Message sending/receiving
    - Reconnection logic with exponential backoff
    - **Why needed**: Core WebSocket client logic

### State Management (Providers)

17. **`quiz_app/lib/providers/session_provider.dart`**
    - Session state management
    - Join session logic
    - Participant tracking
    - WebSocket message handling
    - **Why needed**: Session state and WebSocket integration

18. **`quiz_app/lib/providers/game_provider.dart`**
    - Game state management
    - Question handling
    - Answer submission
    - Timer management
    - **Why needed**: Game logic and question flow

19. **`quiz_app/lib/providers/leaderboard_provider.dart`**
    - Leaderboard state management
    - Score updates
    - Ranking display
    - **Why needed**: Leaderboard functionality

### UI Screens

20. **`quiz_app/lib/screens/multiplayer/lobby_screen.dart`**
    - Waiting lobby UI
    - Participant list display
    - Start quiz button (host only)
    - Session code display
    - **Why needed**: Pre-game lobby interface

21. **`quiz_app/lib/screens/multiplayer/quiz_screen.dart`**
    - Active quiz gameplay UI
    - Question display
    - Answer selection
    - Timer display
    - Leaderboard display
    - **Why needed**: Main gameplay interface

22. **`quiz_app/lib/screens/multiplayer/results_screen.dart`**
    - Final results display
    - Winner announcement
    - Final rankings
    - **Why needed**: Post-game results interface

### Data Models

23. **`quiz_app/lib/models/` (all model files)**
    - Participant model
    - QuizQuestion model
    - SessionState model
    - GameState model
    - LeaderboardEntry model
    - **Why needed**: Data structure definitions matching backend

### Configuration

24. **`quiz_app/lib/config/` (API configuration)**
    - API base URL configuration
    - WebSocket URL configuration
    - **Why needed**: Connection endpoints

25. **`quiz_app/pubspec.yaml`**
    - Flutter dependencies
    - web_socket_channel, flutter_riverpod, etc.
    - **Why needed**: Verify required packages

---

## 🗄️ Database & Infrastructure

### Redis (Session State)
- **Purpose**: Real-time session state, participant tracking, leaderboards
- **Key Patterns**:
  - `session:{session_code}` - Session data
  - `leaderboard:{session_code}` - Sorted set for rankings
  - `session_codes` - Set of active session codes
- **Why needed**: Session state persistence and real-time updates

### MongoDB (Persistent Data)
- **Collections**:
  - `quizzes` - Quiz definitions
  - `sessions` - Completed session records
  - `users` - User profiles
- **Why needed**: Quiz data and historical records

---

## 🔍 Common Issues to Check

### 1. Connection Issues
- **Files to check**: 
  - `backend/app/core/config.py` (CORS settings)
  - `backend/.env` (CORS_ORIGINS)
  - `quiz_app/lib/config/` (API URLs)
  - `quiz_app/lib/services/websocket_service.dart` (connection logic)

### 2. Message Routing Issues
- **Files to check**:
  - `backend/app/api/routes/websocket.py` (message handlers)
  - `quiz_app/lib/providers/session_provider.dart` (message parsing)
  - `quiz_app/lib/providers/game_provider.dart` (game messages)

### 3. Session State Issues
- **Files to check**:
  - `backend/app/services/session_manager.py` (Redis operations)
  - `backend/app/services/game_controller.py` (game state)
  - `quiz_app/lib/providers/session_provider.dart` (state sync)

### 4. Timing/Synchronization Issues
- **Files to check**:
  - `backend/app/services/game_controller.py` (timer logic)
  - `quiz_app/lib/providers/game_provider.dart` (client timer)
  - `backend/app/api/routes/websocket.py` (broadcast timing)

### 5. Leaderboard Issues
- **Files to check**:
  - `backend/app/services/leaderboard_manager.py` (Redis sorted sets)
  - `quiz_app/lib/providers/leaderboard_provider.dart` (leaderboard state)

### 6. Reconnection Issues
- **Files to check**:
  - `quiz_app/lib/services/websocket_service.dart` (reconnection logic)
  - `backend/app/services/connection_manager.py` (connection tracking)
  - `backend/app/api/routes/websocket.py` (reconnection handling)

---

## 🧪 Testing Files

26. **`backend/tests/` (all test files)**
    - Unit tests for services
    - Integration tests for WebSocket
    - **Why needed**: Verify backend functionality

27. **`backend/test_api_automated.py`**
    - Automated API tests
    - **Why needed**: End-to-end testing

28. **`backend/test_session_endpoints.py`**
    - Session-specific tests
    - **Why needed**: Session functionality verification

---

## 📝 Documentation Files

29. **`WEBSOCKET_FIX.md`**
    - Previous WebSocket 403 fix documentation
    - CORS configuration details
    - Testing checklist
    - **Why needed**: Historical context and known fixes

30. **`tasks.md`**
    - Complete implementation checklist
    - Feature status
    - **Why needed**: Implementation completeness verification

31. **`TECHNICAL_FEATURES.md`**
    - Feature specifications
    - Multiplayer requirements
    - **Why needed**: Feature requirements and expected behavior

32. **`SRS_DOCUMENT.md`**
    - Software Requirements Specification
    - System architecture
    - **Why needed**: Overall system design

---

## 🚀 How to Use This Context

### For AI Debugging Tools

**Attach these files in order of priority:**

#### Priority 1 (Critical - Always Include):
1. `backend/app/api/routes/websocket.py`
2. `backend/app/services/websocket_manager.py`
3. `backend/app/services/session_manager.py`
4. `quiz_app/lib/services/websocket_service.dart`
5. `quiz_app/lib/providers/session_provider.dart`
6. `backend/app/core/config.py`
7. `backend/.env`

#### Priority 2 (Important - Include if space allows):
8. `backend/app/services/game_controller.py`
9. `backend/app/services/leaderboard_manager.py`
10. `quiz_app/lib/providers/game_provider.dart`
11. `quiz_app/lib/providers/leaderboard_provider.dart`
12. `quiz_app/lib/screens/multiplayer/lobby_screen.dart`
13. `quiz_app/lib/screens/multiplayer/quiz_screen.dart`

#### Priority 3 (Supporting - Include for specific issues):
14. `backend/app/models/session.py`
15. `backend/app/models/quiz.py`
16. `quiz_app/lib/models/` (relevant model files)
17. `backend/app/api/routes/sessions.py`
18. `WEBSOCKET_FIX.md`

### For Manual Debugging

1. **Start with logs**: Check backend console and Flutter debug console
2. **Verify connections**: Ensure Redis and MongoDB are running
3. **Check CORS**: Verify `backend/.env` has correct CORS_ORIGINS
4. **Test WebSocket**: Use browser dev tools or Postman to test WebSocket endpoint
5. **Review message flow**: Add logging to track message routing
6. **Check state sync**: Verify Redis contains expected session data

---

## 🔗 Key Endpoints

### REST API
- `POST /api/sessions/create` - Create new session
- `GET /api/sessions/{session_code}` - Get session info
- `GET /api/quizzes/{quiz_id}` - Get quiz data

### WebSocket
- `ws://localhost:8000/ws/{session_code}?user_id={user_id}` - WebSocket connection

### Message Types (WebSocket)
- `join` - Join session
- `start_quiz` - Start quiz (host only)
- `submit_answer` - Submit answer
- `end_quiz` - End quiz early (host only)
- `ping` - Heartbeat

---

## 📊 System Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Frontend)     │
└────────┬────────┘
         │ WebSocket
         │ (ws://)
         ↓
┌─────────────────┐
│  FastAPI        │
│  (Backend)      │
└────┬───────┬────┘
     │       │
     ↓       ↓
┌────────┐ ┌──────────┐
│ Redis  │ │ MongoDB  │
│(State) │ │ (Data)   │
└────────┘ └──────────┘
```

---

## ✅ Pre-Debug Checklist

Before debugging, verify:
- [ ] Backend server is running (`uvicorn app.main:app --reload`)
- [ ] Redis is running and accessible
- [ ] MongoDB is running and accessible
- [ ] Flutter app can reach backend (check API URL in config)
- [ ] CORS is properly configured in `backend/.env`
- [ ] All dependencies are installed (backend and frontend)
- [ ] No firewall blocking WebSocket connections
- [ ] Session codes are being generated correctly
- [ ] WebSocket URL format is correct (no trailing `#` or special characters)

---

## 🐛 Common Error Patterns

### "WebSocket connection failed with status 403"
- **Check**: CORS configuration in `backend/app/core/config.py` and `backend/.env`
- **Files**: `backend/app/core/config.py`, `backend/.env`

### "Session not found"
- **Check**: Redis connection and session creation logic
- **Files**: `backend/app/services/session_manager.py`, `backend/app/api/routes/sessions.py`

### "Message not received by clients"
- **Check**: WebSocket broadcast logic and connection tracking
- **Files**: `backend/app/services/websocket_manager.py`, `backend/app/api/routes/websocket.py`

### "Timer not synchronized"
- **Check**: Timer start/stop logic on both backend and frontend
- **Files**: `backend/app/services/game_controller.py`, `quiz_app/lib/providers/game_provider.dart`

### "Leaderboard not updating"
- **Check**: Redis sorted set operations and score updates
- **Files**: `backend/app/services/leaderboard_manager.py`, `quiz_app/lib/providers/leaderboard_provider.dart`

### "Reconnection not working"
- **Check**: Reconnection logic and state restoration
- **Files**: `quiz_app/lib/services/websocket_service.dart`, `backend/app/services/connection_manager.py`

---

## 📞 Support Information

- **Backend Framework**: FastAPI (Python)
- **Frontend Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **WebSocket Library**: `web_socket_channel` (Flutter), `websockets` (FastAPI)
- **Session Store**: Redis
- **Database**: MongoDB
- **Real-time Communication**: WebSocket protocol

---

**Last Updated**: November 20, 2025
**Status**: Implementation Complete, Ready for Debugging
