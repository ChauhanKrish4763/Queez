import pytest
from app.services.session_manager import SessionManager
from app.services.game_controller import GameController
from app.services.leaderboard_manager import LeaderboardManager
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
    
    # Add scores
    await leaderboard_manager.update_score(session_code, "user1", 1500)
    await leaderboard_manager.update_score(session_code, "user2", 2000)
    await leaderboard_manager.update_score(session_code, "user3", 1000)
    
    # Get rankings
    rankings = await leaderboard_manager.get_rankings(session_code, limit=10)
    assert len(rankings) == 3
    assert rankings[0]["user_id"] == "user2"
    assert rankings[0]["score"] == 2000
    assert rankings[0]["rank"] == 1
    
    # Get user rank
    rank = await leaderboard_manager.get_user_rank(session_code, "user1")
    assert rank == 2
    
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
