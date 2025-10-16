# 📋 Quick API Reference Sheet

## 🔗 All API Endpoints Summary

### Base URL: `http://localhost:8000`

---

## 1️⃣ **Health & Basic**

| Method | Endpoint | Purpose          | Body Required |
| ------ | -------- | ---------------- | ------------- |
| GET    | `/`      | Check API status | No            |

---

## 2️⃣ **Quiz CRUD (6 endpoints)**

| Method | Endpoint             | Purpose          | Body Required |
| ------ | -------------------- | ---------------- | ------------- |
| POST   | `/quizzes`           | Create new quiz  | ✅ Yes        |
| GET    | `/quizzes/library`   | Get all quizzes  | No            |
| GET    | `/quizzes/{quiz_id}` | Get single quiz  | No            |
| PUT    | `/quizzes/{quiz_id}` | Full update quiz | ✅ Yes        |
| PATCH  | `/quizzes/{quiz_id}` | Partial update   | ✅ Yes        |
| DELETE | `/quizzes/{quiz_id}` | Delete quiz      | No            |

---

## 3️⃣ **Search & Filter (3 endpoints)**

| Method | Endpoint                       | Purpose            | Query Params |
| ------ | ------------------------------ | ------------------ | ------------ |
| GET    | `/quizzes/search`              | Search quizzes     | `?q=keyword` |
| GET    | `/quizzes/category/{category}` | Filter by category | -            |
| GET    | `/quizzes/language/{language}` | Filter by language | -            |

---

## 4️⃣ **Statistics & Attempts (3 endpoints)**

| Method | Endpoint                      | Purpose             | Body Required |
| ------ | ----------------------------- | ------------------- | ------------- |
| GET    | `/quizzes/{quiz_id}/stats`    | Get quiz statistics | No            |
| POST   | `/quizzes/{quiz_id}/attempt`  | Record attempt      | ✅ Yes        |
| GET    | `/quizzes/{quiz_id}/attempts` | Get all attempts    | No            |

---

## 5️⃣ **User Management (4 endpoints)**

| Method | Endpoint                   | Purpose            | Body Required |
| ------ | -------------------------- | ------------------ | ------------- |
| POST   | `/users`                   | Create user        | ✅ Yes        |
| GET    | `/users/{user_id}`         | Get user profile   | No            |
| PUT    | `/users/{user_id}`         | Update user        | ✅ Yes        |
| GET    | `/users/{user_id}/quizzes` | Get user's quizzes | No            |

---

## 6️⃣ **Reviews & Ratings (3 endpoints)**

| Method | Endpoint                     | Purpose           | Body Required |
| ------ | ---------------------------- | ----------------- | ------------- |
| POST   | `/quizzes/{quiz_id}/reviews` | Add review        | ✅ Yes        |
| GET    | `/quizzes/{quiz_id}/reviews` | Get reviews       | No            |
| GET    | `/quizzes/top-rated`         | Top rated quizzes | No            |

---

## 7️⃣ **Results & Leaderboard (3 endpoints)**

| Method | Endpoint                 | Purpose         | Body Required |
| ------ | ------------------------ | --------------- | ------------- |
| POST   | `/results`               | Submit result   | ✅ Yes        |
| GET    | `/results/{quiz_id}`     | Get all results | No            |
| GET    | `/leaderboard/{quiz_id}` | Get leaderboard | No            |

---

## 8️⃣ **Categories, Languages & Tags (4 endpoints)**

| Method | Endpoint      | Purpose            | Body Required |
| ------ | ------------- | ------------------ | ------------- |
| GET    | `/categories` | Get all categories | No            |
| GET    | `/languages`  | Get all languages  | No            |
| GET    | `/tags`       | Get all tags       | No            |
| POST   | `/tags`       | Create tag         | ✅ Yes        |

---

## 9️⃣ **Dashboard (1 endpoint)**

| Method | Endpoint           | Purpose            | Body Required |
| ------ | ------------------ | ------------------ | ------------- |
| GET    | `/dashboard/stats` | Overall statistics | No            |

---

## 📦 Sample Request Bodies

### Create Quiz

```json
{
  "title": "Quiz Title",
  "description": "Description here",
  "language": "English",
  "category": "Science and Technology",
  "questions": [
    {
      "id": "1",
      "questionText": "Question?",
      "type": "single",
      "options": ["A", "B", "C", "D"],
      "correctAnswerIndex": 0
    }
  ]
}
```

### Create User

```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "full_name": "John Doe",
  "bio": "Developer"
}
```

### Record Attempt

```json
{
  "user_id": "user123",
  "score": 8,
  "total_questions": 10,
  "time_taken": 120,
  "answers": []
}
```

### Add Review

```json
{
  "user_id": "user123",
  "username": "John Doe",
  "rating": 5,
  "comment": "Great quiz!"
}
```

### Submit Result

```json
{
  "quiz_id": "67abc...",
  "user_id": "user123",
  "username": "John Doe",
  "score": 9,
  "total_questions": 10,
  "percentage": 90,
  "time_taken": 180
}
```

### Create Tag

```json
{
  "name": "beginner",
  "description": "For beginners"
}
```

---

## 🎯 Testing Sequence (Logical Order)

1. ✅ Health Check → Verify API is running
2. ✅ Create Quiz → Get quiz_id
3. ✅ Get All Quizzes → Verify it's in library
4. ✅ Get Quiz by ID → See full details
5. ✅ Search Quiz → Test search functionality
6. ✅ Create User → Get user_id
7. ✅ Record Attempt → Log quiz attempt
8. ✅ Get Stats → View statistics
9. ✅ Add Review → Rate the quiz
10. ✅ Get Reviews → See all reviews
11. ✅ Submit Result → Add to leaderboard
12. ✅ Get Leaderboard → View rankings
13. ✅ Update Quiz → Modify quiz
14. ✅ Get Categories → View categories
15. ✅ Dashboard Stats → Overall metrics
16. ✅ Delete Quiz → Clean up

---

## 🔄 HTTP Status Codes

| Code | Meaning      | When You'll See It             |
| ---- | ------------ | ------------------------------ |
| 200  | OK           | Successful GET, PUT, PATCH     |
| 201  | Created      | Not used (returns 200)         |
| 400  | Bad Request  | Missing required fields        |
| 404  | Not Found    | Invalid ID or deleted resource |
| 500  | Server Error | Database or code error         |

---

## 💡 Pro Tips

### Variables in Postman

- `{{base_url}}` → `http://localhost:8000`
- `{{quiz_id}}` → Auto-saved when creating quiz
- `{{user_id}}` → Auto-saved when creating user

### Testing Error Cases

- Try invalid ID: `12345` → Should get 500/404
- Try deleted resource → Should get 404
- Try empty body on POST → Should get 422

### Query Parameters

- Add `?limit=5` to limit results
- Add `?q=python` for search terms
- Multiple params: `?limit=10&offset=0`

---

## 🗄️ MongoDB Collections Created

Your API will automatically create these collections:

1. `quizzes` - Main quiz data
2. `users` - User profiles
3. `quiz_attempts` - Quiz attempt records
4. `quiz_reviews` - Reviews and ratings
5. `quiz_results` - Quiz results
6. `tags` - Custom tags

---

## 📊 Example Testing Flow

```
1. POST /quizzes → Create "Python Quiz"
   Response: { "id": "67abc123..." }

2. GET /quizzes/library → See all quizzes
   Response: { "count": 1, "data": [...] }

3. POST /users → Create user "John"
   Response: { "user_id": "67def456..." }

4. POST /quizzes/67abc123/attempt
   Body: { "user_id": "67def456", "score": 8 }
   Response: { "percentage": 80 }

5. GET /quizzes/67abc123/stats
   Response: { "total_attempts": 1, "average_score": 8.0 }

6. POST /quizzes/67abc123/reviews
   Body: { "rating": 5, "comment": "Great!" }
   Response: { "success": true }

7. GET /leaderboard/67abc123
   Response: { "leaderboard": [{rank: 1, score: 8}] }
```

---

## 🚀 Quick Commands

### Start Server

```bash
cd backend
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Check Server in Browser

```
http://localhost:8000
```

### View API Docs (Auto-generated by FastAPI)

```
http://localhost:8000/docs
```

---

## ✨ Impressive Demo Points

1. **CRUD Mastery**: "We have complete CRUD operations"
2. **Search**: "Real-time search across quiz titles and descriptions"
3. **Analytics**: "Built-in statistics and attempt tracking"
4. **Leaderboard**: "Competitive leaderboard system"
5. **Reviews**: "User ratings and review system"
6. **Filtering**: "Filter by category, language, or search term"
7. **Dashboard**: "Administrative dashboard with metrics"
8. **RESTful**: "Follows REST API best practices"

---

**Total Endpoints: 31**

- GET: 20 endpoints
- POST: 7 endpoints
- PUT: 2 endpoints
- PATCH: 1 endpoint
- DELETE: 1 endpoint

**You're ready to impress! 🎉**
