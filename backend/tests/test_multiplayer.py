import pytest
from app.services.session_manager import SessionManager
from app.services.game_controller import GameController
from app.services.leaderboard_manager import LeaderboardManager
from datetime import datetime
from bson import ObjectId

# Mock Redis
class MockRedis:
    def __init__(self):
        self.data = {}

    async def hset(self, name, key=None, value=None, mapping=None):
        if name not in self.data:
            self.data[name] = {}
        if mapping:
            self.data[name].update(mapping)
        if key and value:
            self.data[name][key] = value

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
        self.data[name][key] = val + amount
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
        items = sorted(self.data[name].items(), key=lambda x: x[1], reverse=True)
        return items[start:end+1] if withscores else [x[0] for x in items[start:end+1]]

    async def zrevrank(self, name, member):
        if name not in self.data:
            return None
        items = sorted(self.data[name].items(), key=lambda x: x[1], reverse=True)
        for i, (k, v) in enumerate(items):
            if k == member:
                return i
        return None

    async def delete(self, name):
        if name in self.data:
            del self.data[name]

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

@pytest.mark.asyncio
async def test_create_session(session_manager, monkeypatch):
    quiz_id = str(ObjectId())
    
    # Mock quiz fetching
    async def mock_find_one(*args, **kwargs):
        return {"_id": ObjectId(quiz_id), "title": "Test Quiz", "questions": [{}, {}]}
    
    monkeypatch.setattr("app.core.database.collection.find_one", mock_find_one)
    
    session_code = await session_manager.create_session(quiz_id, "host123")
    assert len(session_code) == 6
    
    session = await session_manager.get_session(session_code)
    assert session["quiz_id"] == quiz_id
    assert session["host_id"] == "host123"
    assert session["status"] == "waiting"

@pytest.mark.asyncio
async def test_add_participant(session_manager, monkeypatch):
    quiz_id = str(ObjectId())
    
    # Setup session
    async def mock_find_one(*args, **kwargs):
        return {"_id": ObjectId(quiz_id), "title": "Test Quiz", "questions": []}
    monkeypatch.setattr("app.core.database.collection.find_one", mock_find_one)
    
    code = await session_manager.create_session(quiz_id, "host123")
    
    # Add participant
    await session_manager.add_participant(code, "user1", "User 1")
    
    session = await session_manager.get_session(code)
    participants = session["participants"]
    assert "user1" in participants
    assert participants["user1"]["username"] == "User 1"

@pytest.mark.asyncio
async def test_start_session(session_manager, monkeypatch):
    quiz_id = str(ObjectId())
    
    async def mock_find_one(*args, **kwargs):
        return {"_id": ObjectId(quiz_id), "title": "Test Quiz", "questions": []}
    monkeypatch.setattr("app.core.database.collection.find_one", mock_find_one)
    
    code = await session_manager.create_session(quiz_id, "host123")
    
    # Non-host cannot start
    assert not await session_manager.start_session(code, "user1")
    
    # Host can start
    assert await session_manager.start_session(code, "host123")
    
    session = await session_manager.get_session(code)
    assert session["status"] == "active"
