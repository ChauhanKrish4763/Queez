import redis.asyncio as redis
from app.core.config import REDIS_URL, REDIS_MAX_CONNECTIONS

# Redis connection pool
redis_pool = None
redis_client = None

async def init_redis():
    """Initialize Redis connection pool"""
    global redis_pool, redis_client
    redis_pool = redis.ConnectionPool.from_url(
        REDIS_URL,
        max_connections=REDIS_MAX_CONNECTIONS,
        decode_responses=True
    )
    redis_client = redis.Redis(connection_pool=redis_pool)
    return redis_client

async def close_redis():
    """Close Redis connection pool"""
    global redis_pool, redis_client
    if redis_client:
        await redis_client.close()
    if redis_pool:
        await redis_pool.disconnect()

def get_redis():
    """Get Redis client instance"""
    return redis_client
