# AI Study Set Generation - Setup Guide

## Overview
This feature allows users to upload documents (PDF, PPT, DOC, TXT) and automatically generate quizzes, flashcards, and notes using Google's Gemini 2.0 Flash AI model.

## Architecture
1. **Frontend (Flutter)** - User uploads files, configures settings
2. **Gemini File API** - Temporary file storage with upload tokens
3. **Backend (FastAPI)** - Orchestrates AI generation
4. **Gemini 2.0 Flash** - Generates study materials

## Backend Setup

### 1. Install Dependencies
```bash
cd Queez-Backend
pip install -r requirements.txt
```

### 2. Set Environment Variable
Add your Gemini API key to Render environment variables:

**Variable Name:** `GEMINI_API_KEY`  
**Value:** Your API key from https://aistudio.google.com/apikey

### 3. Deploy to Render
The backend will automatically deploy when you push to GitHub. Render will:
- Install `google-generativeai` package
- Load `GEMINI_API_KEY` from environment
- Expose endpoints at `/ai/get-upload-token` and `/ai/generate-study-set`

## Frontend Setup

### 1. Dependencies Already Added
- `file_picker` - File selection
- `http` - API requests
- `lottie` - Loading animations
- `flutter_riverpod` - State management

### 2. Routes Already Configured
- `/study_set_mode_selection` - Choose Manual or AI creation
- AI Configuration screen with file uploads
- AI Progress screen with real-time updates

## How It Works

### User Flow:
1. User taps "Study Set" from Create page
2. Chooses "AI Generated" mode
3. Uploads 1-3 documents (max 10MB each)
4. Fills study set details (name, description, category, language)
5. Configures generation settings (quiz count, difficulty, etc.)
6. Taps "Generate Study Set"
7. Progress screen shows real-time updates
8. Success dialog appears when complete

### Technical Flow:
1. **Get Upload Token** (10-min expiry)
   ```
   GET /ai/get-upload-token
   Authorization: Bearer {firebase_token}
   → Returns: { uploadToken, expiresAt }
   ```

2. **Upload Files to Gemini**
   ```
   POST https://generativelanguage.googleapis.com/upload/v1beta/files
   Authorization: Bearer {upload_token}
   Body: multipart form with file
   → Returns: { file: { uri: "files/abc123", displayName, mimeType } }
   ```

3. **Generate Study Set**
   ```
   POST /ai/generate-study-set
   Authorization: Bearer {firebase_token}
   Body: {
     fileUris: ["files/abc123", "files/def456"],
     config: { name, description, category, language },
     settings: { quizCount, flashcardSetCount, difficulty, ... }
   }
   → Returns: { success: true, studySet: { quizzes, flashcardSets, notes } }
   ```

## File Structure

### Frontend
```
lib/
├── CreateSection/
│   ├── screens/
│   │   ├── study_set_mode_selection.dart      # Manual vs AI choice
│   │   ├── ai_study_set_configuration.dart    # File upload + settings
│   │   └── ai_generation_progress.dart        # Progress tracking
│   ├── models/
│   │   └── ai_study_set_models.dart           # Data models
│   ├── services/
│   │   └── ai_study_set_service.dart          # API calls
│   └── providers/
│       └── ai_study_set_provider.dart         # Riverpod state management
```

### Backend
```
app/
├── api/
│   └── routes/
│       └── ai_generation.py     # /ai/* endpoints
├── main.py                      # Router registration
└── requirements.txt             # Dependencies including google-generativeai
```

## Security

### Upload Tokens
- Generated with `secrets.token_urlsafe(32)`
- Valid for 10 minutes only
- Stored in memory (use Redis for production)
- Scoped to authenticated users only

### API Keys
- `GEMINI_API_KEY` stored in Render environment (never in code)
- Master key only accessible by backend
- Frontend never sees the master API key

## Error Handling

### Frontend
- File size validation (10MB limit)
- File type validation (PDF, PPT, DOC, TXT)
- Network timeout (3 minutes for generation)
- Token expiration handling
- User-friendly error dialogs

### Backend
- Authorization validation
- File count limits (max 3)
- Config validation (name ≥3 chars, description ≥10 chars)
- JSON parsing with markdown code block extraction
- Comprehensive logging

## Testing

### Local Testing
1. Run backend locally:
   ```bash
   cd Queez-Backend
   export GEMINI_API_KEY="your_key_here"
   uvicorn app.main:app --reload
   ```

2. Update Flutter `api_config.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:8000';
   ```

3. Run Flutter app and test the flow

### Production Testing
1. Ensure `GEMINI_API_KEY` is set in Render
2. Check backend logs for errors
3. Test with small documents first
4. Verify all 3 content types are generated (quizzes, flashcards, notes)

## Prompt Engineering

The AI prompt includes:
- Study set metadata (name, description, category, language)
- Generation requirements (quiz count, flashcard count, note count)
- Difficulty level and question counts
- Output format specification (JSON structure)
- Quality requirements (understanding over memorization)

## Future Enhancements

1. **Redis Integration** - Replace in-memory token storage
2. **Progress Streaming** - Real-time progress updates via WebSocket
3. **Image Support** - Upload images for visual quizzes
4. **Custom Templates** - User-defined study material templates
5. **Regeneration** - Regenerate specific quizzes or flashcards
6. **Export** - Export generated materials to PDF/Anki

## Troubleshooting

### "Upload token not available"
- Token expired (>10 minutes)
- Network issue during token fetch
- **Fix:** Retry upload, service will fetch new token

### "Generation failed"
- Gemini API quota exceeded
- Invalid file format
- File too large or complex
- **Fix:** Check backend logs, try smaller documents

### "Failed to parse AI response"
- Gemini returned invalid JSON
- Network timeout
- **Fix:** Retry generation, may succeed on second attempt

## API Documentation

Once deployed, visit:
- **Local:** http://localhost:8000/docs
- **Production:** https://queez-backend.onrender.com/docs

Look for `/ai/*` endpoints in the "AI Generation" section.
