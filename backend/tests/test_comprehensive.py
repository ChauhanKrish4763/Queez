import pytest
from app.services.session_manager import SessionManager
from app.services.game_controller import GameController
from app.services.leaderboard_manager import LeaderboardManager
from app.core.database import redis_client
from datetime import datetime
import json
from bson import ObjectId

# Mock Redis
class MockRedis:
    def __init__(self):
        self.data = {}

    async def hset(self, name, key=None, value=None, mapping=None):
        if name not in self.data:
            self.data[name] = {}
        if mapping:
            for k, v in mapping.items():
                self.data[name][k] = str(v) if not isinstance(v, str) else v
        if key and value:
            self.data[name][key] = str(value) if not isinstance(value, str) else value

    async def hget(self, name, key):
        return self.data.get(name, {}).get(key)

    async def hgetall(self, name):
        return self.data.get(name, {})

    async def exists(self, name):
        return name in self.data

    async def expire(self, name, time):
        pass
    
    async def hincrby(self, name, key, amount):
        if name not in self.data:
            self.data[name] = {}
        val = int(self.data[name].get(key, 0))
        self.data[name][key] = str(val + amount)
        return val + amount

    async def hmget(self, name, keys):
        return [self.data.get(name, {}).get(k) for k in keys]

    async def zadd(self, name, mapping):
        if name not in self.data:
            self.data[name] = {}
        self.data[name].update(mapping)

    async def zrevrange(self, name, start, end, withscores=False):
        if name not in self.data:
            return []
        items = sorted(self.data[name].items(), key=lambda x: float(x[1]), reverse=True)
        return items[start:end+1] if withscores else [x[0] for x in items[start:end+1]]

    async def zrevrank(self, name, member):
        if name not in self.data:
            return None
        items = sorted(self.data[name].items(), key=lambda x: float(x[1]), reverse=True)
        for i, (k, v) in enumerate(items):
            if k == member:
                return i
        return None

    async def delete(self, name):
        if name in self.data:
            del self.data[name]
    
    async def setex(self, name, time, value):
        self.data[name] = value
    
    async def get(self, name):
        return self.data.get(name)
    
    async def set(self, name, value):
        self.data[name] = str(value) if not isinstance(value, str) else value

@pytest.fixture
def mock_redis():
    return MockRedis()

@pytest.fixture
def session_manager(mock_redis):
    manager = SessionManager()
    manager.redis = mock_redis
    return manager

@pytest.fixture
def game_controller(mock_redis):
    controller = GameController()
    controller.redis = mock_redis
    return controller

@pytest.fixture
def leaderboard_manager(mock_redis):
    manager = LeaderboardManager()
    manager.redis = mock_redis
    return manager

@pytest.mark.asyncio
async def test_leaderboard_operations(leaderboard_manager):
    """Test leaderboard CRUD operations"""
    session_code = "TEST123"
    
    # Setup session with participants in Redis
    session_key = f"session:{session_code}"
    participants = {
        "user1": {
            "user_id": "user1",
            "username": "User1",
            "score": 1500,
            "connected": True,
            "answers": []
        },
        "user2": {
            "user_id": "user2",
            "username": "User2",
            "score": 2000,
            "connected": True,
            "answers": []
        },
        "user3": {
            "user_id": "user3",
            "username": "User3",
            "score": 1000,
            "connected": True,
            "answers": []
        }
    }
    
    await redis_client.hset(session_key, mapping={
        "participants": json.dumps(participants),
        "current_question_index": "0",
        "total_questions": "5"
    })
    
    # Get leaderboard
    leaderboard = await leaderboard_manager.get_leaderboard(session_code)
    assert len(leaderboard) == 3
    assert leaderboard[0]["user_id"] == "user2"
    assert leaderboard[0]["score"] == 2000
    assert leaderboard[0]["position"] == 1
    
    # Get user rank
    rank_info = await leaderboard_manager.get_participant_rank(session_code, "user1")
    assert rank_info["position"] == 2
    
    # Cleanup
    await redis_client.delete(session_key)
    
    # Clear leaderboard
    await leaderboard_manager.clear_leaderboard(session_code)
    rankings = await leaderboard_manager.get_rankings(session_code)
    assert len(rankings) == 0

@pytest.mark.asyncio
async def test_session_creation(session_manager, monkeypatch):
    """Test session creation with valid ObjectId"""
    quiz_id = str(ObjectId())
    
    async def mock_find_one(*args, **kwargs):
        return {
            "_id": ObjectId(quiz_id),
            "title": "Test Quiz",
            "questions": [{"question_text": "Q1"}]
        }
    monkeypatch.setattr("app.core.database.collection.find_one", mock_find_one)
    
    code = await session_manager.create_session(quiz_id, "host")
    assert len(code) == 6
    
    session = await session_manager.get_session(code)
    assert session["quiz_id"] == quiz_id
    assert session["host_id"] == "host"
    assert session["status"] == "waiting"

@pytest.mark.asyncio
async def test_get_current_question_includes_text_and_type(game_controller, mock_redis, monkeypatch):
    """Test that get_current_question includes question text and questionType fields"""
    quiz_id = str(ObjectId())
    session_code = "TEST123"
    
    # Mock quiz with proper question structure
    async def mock_find_one(*args, **kwargs):
        return {
            "_id": ObjectId(quiz_id),
            "title": "Test Quiz",
            "questions": [
                {
                    "id": "q1",
                    "questionText": "What is Python?",
                    "type": "single",
                    "options": ["A language", "A snake", "A software", "An OS"],
                    "correctAnswerIndex": 0
                },
                {
                    "id": "q2",
                    "questionText": "Is Python open source?",
                    "type": "trueFalse",
                    "options": ["True", "False"],
                    "correctAnswerIndex": 0
                }
            ]
        }
    monkeypatch.setattr("app.core.database.collection.find_one", mock_find_one)
    
    # Set up session data in mock Redis
    await mock_redis.hset(f"session:{session_code}", mapping={
        "quiz_id": quiz_id,
        "current_question_index": "0",
        "question_start_time": datetime.utcnow().isoformat()
    })
    
    # Get current question
    question_data = await game_controller.get_current_question(session_code)
    
    # Verify structure
    assert question_data is not None
    assert "question" in question_data
    assert "index" in question_data
    assert "total" in question_data
    assert "time_remaining" in question_data
    
    # Verify question payload has required fields
    question = question_data["question"]
    assert "question" in question, "Question text field missing"
    assert "questionType" in question, "Question type field missing"
    assert question["question"] == "What is Python?"
    assert question["questionType"] == "single"
    assert question["type"] == "single"  # Backward compatibility
    assert "options" in question
    assert len(question["options"]) == 4

@pytest.mark.asyncio
async def test_get_current_question_validates_empty_text(game_controller, mock_redis, monkeypatch):
    """Test that get_current_question returns None for empty question text"""
    quiz_id = str(ObjectId())
    session_code = "TEST456"
    
    # Mock quiz with empty question text
    async def mock_find_one(*args, **kwargs):
        return {
            "_id": ObjectId(quiz_id),
            "title": "Test Quiz",
            "questions": [
                {
                    "id": "q1",
                    "questionText": "",  # Empty text
                    "type": "single",
                    "options": ["A", "B", "C", "D"],
                    "correctAnswerIndex": 0
                }
            ]
        }
    monkeypatch.setattr("app.core.database.collection.find_one", mock_find_one)
    
    # Set up session data in mock Redis
    await mock_redis.hset(f"session:{session_code}", mapping={
        "quiz_id": quiz_id,
        "current_question_index": "0",
        "question_start_time": datetime.utcnow().isoformat()
    })
    
    # Get current question should return None for empty text
    question_data = await game_controller.get_current_question(session_code)
    assert question_data is None

@pytest.mark.asyncio
async def test_get_current_question_handles_legacy_field_names(game_controller, mock_redis, monkeypatch):
    """Test that get_current_question handles legacy 'question' field name"""
    quiz_id = str(ObjectId())
    session_code = "TEST789"
    
    # Mock quiz with legacy field name
    async def mock_find_one(*args, **kwargs):
        return {
            "_id": ObjectId(quiz_id),
            "title": "Test Quiz",
            "questions": [
                {
                    "id": "q1",
                    "question": "Legacy question text",  # Using 'question' instead of 'questionText'
                    "type": "single",
                    "options": ["A", "B"],
                    "correctAnswerIndex": 0
                }
            ]
        }
    monkeypatch.setattr("app.core.database.collection.find_one", mock_find_one)
    
    # Set up session data in mock Redis
    await mock_redis.hset(f"session:{session_code}", mapping={
        "quiz_id": quiz_id,
        "current_question_index": "0",
        "question_start_time": datetime.utcnow().isoformat()
    })
    
    # Get current question
    question_data = await game_controller.get_current_question(session_code)
    
    # Verify it handles legacy field name
    assert question_data is not None
    question = question_data["question"]
    assert question["question"] == "Legacy question text"

@pytest.mark.asyncio
async def test_self_paced_progression(game_controller, mock_redis, monkeypatch):
    """Test that participants progress independently through questions (Bug 3 fix)"""
    quiz_id = str(ObjectId())
    session_code = "SELFPACED"
    
    # Mock quiz with 3 questions
    async def mock_find_one(*args, **kwargs):
        return {
            "_id": ObjectId(quiz_id),
            "title": "Self-Paced Quiz",
            "questions": [
                {
                    "id": "q1",
                    "questionText": "Question 1",
                    "type": "singleMcq",
                    "options": ["A", "B", "C", "D"],
                    "correctAnswerIndex": 0
                },
                {
                    "id": "q2",
                    "questionText": "Question 2",
                    "type": "singleMcq",
                    "options": ["A", "B", "C", "D"],
                    "correctAnswerIndex": 1
                },
                {
                    "id": "q3",
                    "questionText": "Question 3",
                    "type": "singleMcq",
                    "options": ["A", "B", "C", "D"],
                    "correctAnswerIndex": 2
                }
            ]
        }
    monkeypatch.setattr("app.core.database.collection.find_one", mock_find_one)
    
    # Set up session with 3 participants
    participants = {
        "user_a": {
            "user_id": "user_a",
            "username": "Participant A",
            "score": 0,
            "connected": True,
            "answers": []
        },
        "user_b": {
            "user_id": "user_b",
            "username": "Participant B",
            "score": 0,
            "connected": True,
            "answers": []
        },
        "user_c": {
            "user_id": "user_c",
            "username": "Participant C",
            "score": 0,
            "connected": True,
            "answers": []
        }
    }
    
    await mock_redis.hset(f"session:{session_code}", mapping={
        "quiz_id": quiz_id,
        "current_question_index": "0",
        "participants": json.dumps(participants)
    })
    
    # Initialize all participants to question 0
    await game_controller.set_participant_question_index(session_code, "user_a", 0)
    await game_controller.set_participant_question_index(session_code, "user_b", 0)
    await game_controller.set_participant_question_index(session_code, "user_c", 0)
    
    # Verify all start at question 0
    assert await game_controller.get_participant_question_index(session_code, "user_a") == 0
    assert await game_controller.get_participant_question_index(session_code, "user_b") == 0
    assert await game_controller.get_participant_question_index(session_code, "user_c") == 0
    
    # Participant A answers question 1 and advances
    await game_controller.submit_answer(session_code, "user_a", 0, 5.0)
    await game_controller.set_participant_question_index(session_code, "user_a", 1)
    
    # Verify: A is on question 1, B and C remain on question 0
    assert await game_controller.get_participant_question_index(session_code, "user_a") == 1
    assert await game_controller.get_participant_question_index(session_code, "user_b") == 0
    assert await game_controller.get_participant_question_index(session_code, "user_c") == 0
    
    # Participant B answers question 1 and advances
    await game_controller.submit_answer(session_code, "user_b", 0, 10.0)
    await game_controller.set_participant_question_index(session_code, "user_b", 1)
    
    # Verify: A is on question 1, B is on question 1, C still on question 0
    assert await game_controller.get_participant_question_index(session_code, "user_a") == 1
    assert await game_controller.get_participant_question_index(session_code, "user_b") == 1
    assert await game_controller.get_participant_question_index(session_code, "user_c") == 0
    
    # Participant A answers question 2 and advances to question 2
    await game_controller.submit_answer(session_code, "user_a", 1, 7.0)
    await game_controller.set_participant_question_index(session_code, "user_a", 2)
    
    # Final verification: A is on question 2, B on question 1, C still on question 0
    assert await game_controller.get_participant_question_index(session_code, "user_a") == 2
    assert await game_controller.get_participant_question_index(session_code, "user_b") == 1
    assert await game_controller.get_participant_question_index(session_code, "user_c") == 0
    
    # Verify each participant can get their correct question
    question_a = await game_controller.get_question_by_index(session_code, 2)
    assert question_a["question"]["question"] == "Question 3"
    
    question_b = await game_controller.get_question_by_index(session_code, 1)
    assert question_b["question"]["question"] == "Question 2"
    
    question_c = await game_controller.get_question_by_index(session_code, 0)
    assert question_c["question"]["question"] == "Question 1"
