# WebSocket 403 Error - Fixed

## Problem
WebSocket connections were failing with HTTP 403 error when trying to join live multiplayer sessions.

## Root Cause
**Invalid CORS Configuration**: The backend had `CORS_ORIGINS = ["*"]` with `CORS_CREDENTIALS = True`, which is an **invalid combination** according to CORS specifications. When credentials are enabled, you cannot use wildcard origins - you must explicitly list allowed origins.

## Changes Made

### 1. Fixed CORS Configuration (`backend/app/core/config.py`)
- Removed wildcard `["*"]` for CORS_ORIGINS
- Added explicit origins for localhost and Android emulator
- Added WebSocket protocol origins (ws://)
- Added support for environment variable to add cloudflared or other origins

### 2. Added Input Sanitization (`backend/app/api/routes/websocket.py`)
- Added cleanup of session_code and user_id to remove trailing `#` characters
- Added logging for WebSocket connection attempts

### 3. Updated Environment Configuration (`backend/.env`)
- Added CORS_ORIGINS environment variable documentation
- Added instructions for adding cloudflared tunnel URLs

## How to Test

1. **Restart your FastAPI backend**:
   ```bash
   cd backend
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

2. **Test the WebSocket connection** from your Flutter app:
   - Enter a session code
   - Click "Join Session"
   - The connection should now succeed

## If Using Cloudflared

If you're using cloudflared tunnel, you need to add your tunnel URL to the allowed origins:

1. Get your cloudflared tunnel URL (e.g., `https://your-tunnel.trycloudflare.com`)

2. Add it to your `backend/.env` file:
   ```env
   CORS_ORIGINS=https://your-tunnel.trycloudflare.com,http://your-tunnel.trycloudflare.com
   ```

3. Update your Flutter app to use the tunnel URL instead of localhost

4. Restart the backend

## Additional Notes

- The WebSocket URL should NOT have a trailing `#` - if you see this in logs, check where the session code is being generated
- Make sure Redis is running (required for session management)
- Make sure MongoDB is accessible (required for data persistence)

## Testing Checklist

- [ ] Backend starts without errors
- [ ] Can create a live multiplayer session
- [ ] Can join a session with a code
- [ ] WebSocket connection establishes (no 403 error)
- [ ] Can see other participants in the lobby
- [ ] Host can start the quiz
- [ ] Questions are received by all participants
