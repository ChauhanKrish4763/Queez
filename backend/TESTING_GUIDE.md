# 🧪 Quiz App API Testing Guide

## 📋 Overview

This guide explains how to test your Quiz App API using both **Postman** and **Python automated tests**.

---

## 🚀 Quick Start

### Option 1: Postman Testing (Recommended for Manual Testing)

**File to Import:** `QuizApp_Comprehensive_Testing.postman_collection.json`

#### Steps:

1. **Start your Uvicorn server:**

   ```bash
   cd backend
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

2. **Open Postman**

3. **Import Collection:**

   - Click **Import** button (top left)
   - Select `QuizApp_Comprehensive_Testing.postman_collection.json` from the `backend` folder
   - The collection will be imported with all variables set

4. **Run Tests:**

   - Expand **"✅ SUCCESS TESTS"** folder - Contains 33 working endpoints
   - Expand **"❌ ERROR TESTS"** folder - Contains 10 error scenarios (expected to fail)
   - Expand **"🧹 CLEANUP"** folder - Cleanup test data

5. **Run Entire Collection:**
   - Right-click on collection name
   - Click **"Run Collection"**
   - Click **"Run Quiz App API - Comprehensive with Error Tests"**
   - Watch automated execution!

---

### Option 2: Python Automated Testing

**Files Available:**

- `test_api_automated.py` - Original comprehensive tests (success cases only)
- `test_api_comprehensive.py` - **NEW!** Includes success + error tests

#### Run Tests:

```bash
cd backend
python test_api_comprehensive.py
```

**Features:**

- ✅ Tests all 33+ endpoints automatically
- ❌ Includes 10+ error handling tests
- 🎨 Colored console output
- 📊 Detailed test summary
- ⏱️ Execution time tracking
- 🔍 Response validation

---

## 📁 Test Files Summary

### Postman Collections:

| File                                                    | Description                                               | Use For            |
| ------------------------------------------------------- | --------------------------------------------------------- | ------------------ |
| `QuizApp_Comprehensive_Testing.postman_collection.json` | ⭐ **USE THIS ONE** - Complete with success + error tests | Production testing |
| `QuizApp_API_Collection.postman_collection.json`        | Original collection (success only)                        | Basic testing      |

### Python Scripts:

| File                        | Description                           | Tests                        |
| --------------------------- | ------------------------------------- | ---------------------------- |
| `test_api_comprehensive.py` | ⭐ **USE THIS ONE** - Full test suite | 40+ tests (success + errors) |
| `test_api_automated.py`     | Original automated tests              | 29 tests (success only)      |

---

## 🎯 What's Tested

### ✅ Success Tests (33 endpoints)

1. **Health Check** - API status
2. **Quiz CRUD** - Create, Read, Update, Patch, Delete
3. **Search & Filter** - Search, category, language filters
4. **Sessions** - Create, join, start, manage quiz sessions
5. **Library** - Add quizzes to user library
6. **Users** - Create, read, update user profiles
7. **Reviews** - Add and retrieve quiz reviews
8. **Analytics** - Quiz stats, attempts tracking
9. **Results** - Submit and retrieve quiz results
10. **Leaderboard** - Get top scores
11. **Categories/Tags** - Manage metadata
12. **Dashboard** - Overall statistics

### ❌ Error Tests (10 scenarios)

1. **E1** - Get non-existent quiz (500)
2. **E2** - Get non-existent user (500)
3. **E3** - Create quiz with empty title (400)
4. **E4** - Create quiz with no questions (400)
5. **E5** - Update non-existent quiz (500)
6. **E6** - Delete non-existent quiz (500)
7. **E7** - Get non-existent session (404)
8. **E8** - Join session with invalid code (404)
9. **E9** - Add to library with invalid code (404)
10. **E10** - Access quiz as wrong user (403)

---

## 📊 Sample Output

### Postman:

```
✅ SUCCESS TESTS (33/33 passed)
❌ ERROR TESTS (10/10 handled correctly)
🧹 CLEANUP (1/1 passed)

Total: 44 requests executed
Pass Rate: 100%
```

### Python:

```
╔═══════════════════════════════════════════════╗
║           FINAL TEST RESULTS                  ║
╚═══════════════════════════════════════════════╝

Total Tests Executed: 43
✓ Tests Passed: 43
  (Including 10 error handling tests)
✗ Tests Failed: 0

[████████████████████████████████████████] 100.0%

🎉 ALL TESTS PASSED! 🎉
```

---

## 🔧 Variables Used

### Postman Collection Variables:

- `base_url` - http://localhost:8000
- `quiz_id` - Auto-set when quiz is created
- `user_id` - Auto-set when user is created
- `session_code` - Auto-set when session is created
- `creator_id` - Default: postman_test_user_123

### Python Script:

- Automatically manages all IDs internally
- No manual configuration needed

---

## 💡 Tips

### For Postman:

1. **Run tests in order** - Success tests should run before error tests
2. **Check variables** - Ensure `quiz_id` is set after creating a quiz
3. **Error tests are SUPPOSED to fail** - They test error handling
4. **Use Collection Runner** - For automated sequential execution

### For Python:

1. **Server must be running** - Start uvicorn before running tests
2. **Check colored output** - Green = pass, Red = fail, Yellow = error test
3. **Wait for completion** - Takes ~30-60 seconds for all tests
4. **Review summary** - Shows pass/fail breakdown at end

---

## 🐛 Troubleshooting

### "Connection Error"

- ✅ Make sure uvicorn server is running
- ✅ Check it's on port 8000
- ✅ Test with browser: http://localhost:8000

### "Test Failed"

- ✅ Check if it's an error test (supposed to fail)
- ✅ Review response in Postman/console
- ✅ Verify database connection

### "Variable Not Set"

- ✅ Run "Create Quiz" first to set `quiz_id`
- ✅ Run tests sequentially, not randomly
- ✅ Check collection variables

---

## 📝 API Endpoints Summary

### Base URL: `http://localhost:8000`

**Quiz Management:**

- POST `/quizzes` - Create quiz
- GET `/quizzes/library/{user_id}` - Get user's quizzes
- GET `/quizzes/{id}?user_id={user}` - Get quiz by ID
- PUT `/quizzes/{id}` - Update quiz
- PATCH `/quizzes/{id}` - Partial update
- DELETE `/quizzes/{id}` - Delete quiz

**Search & Filter:**

- GET `/quizzes/search?q={query}` - Search
- GET `/quizzes/category/{category}` - Filter by category
- GET `/quizzes/language/{language}` - Filter by language
- GET `/quizzes/top-rated` - Top rated quizzes

**Sessions:**

- POST `/api/quiz/{id}/create-session` - Create session
- GET `/api/session/{code}` - Get session info
- POST `/api/session/{code}/join` - Join session
- GET `/api/session/{code}/participants` - Get participants
- POST `/api/session/{code}/start` - Start session

**More endpoints:** See Postman collection for complete list

---

## ✅ Checklist

Before running tests:

- [ ] Backend server is running
- [ ] MongoDB is connected
- [ ] Port 8000 is available
- [ ] Postman is installed (for Postman tests)
- [ ] Python + requests library (for Python tests)

---

## 🎓 What You Learned

After running these tests, you've validated:

- ✅ All CRUD operations work correctly
- ✅ Search and filtering function properly
- ✅ Session management handles multi-user scenarios
- ✅ Error handling returns appropriate status codes
- ✅ API follows RESTful conventions
- ✅ Data validation prevents bad inputs

---

## 📞 Need Help?

- Check server logs in terminal
- Review Postman console for request/response
- Look at colored output in Python tests
- Verify MongoDB connection

**Happy Testing! 🚀**
