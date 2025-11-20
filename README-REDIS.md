# Redis Setup for Queez

## Quick Start

### 1. Start Docker Desktop
Make sure Docker Desktop is running on your Windows machine.

### 2. Start Redis
```bash
docker compose up -d
```

### 3. Verify Redis is Running
```bash
docker ps
```

You should see a container named `queez-redis` running.

### 4. Test Redis Connection
```bash
docker exec -it queez-redis redis-cli ping
```

Should return: `PONG`

## Managing Redis

### Stop Redis
```bash
docker compose down
```

### Stop Redis and Remove Data
```bash
docker compose down -v
```

### View Redis Logs
```bash
docker logs queez-redis
```

### Access Redis CLI
```bash
docker exec -it queez-redis redis-cli
```

## Troubleshooting

### Connection Refused Error
If you see `[Errno 10061] Connect call failed`, it means:
1. Docker Desktop is not running - **Start Docker Desktop**
2. Redis container is not running - Run `docker compose up -d`

### Check Redis Status
```bash
docker compose ps
```

### Restart Redis
```bash
docker compose restart redis
```

## Configuration

Redis is configured in `docker-compose.yml`:
- **Port**: 6379 (mapped to localhost:6379)
- **Data Persistence**: Enabled with volume `redis-data`
- **Health Check**: Automatic health monitoring
- **Auto-restart**: Container restarts automatically unless stopped

Your backend connects to Redis using the URL in `.env`:
```
REDIS_URL=redis://localhost:6379
```
