from typing import Dict, List, Any
from fastapi import WebSocket
import json
import logging

logger = logging.getLogger(__name__)

class ConnectionManager:
    def __init__(self):
        # Map session_code -> list of WebSockets
        self.active_connections: Dict[str, List[WebSocket]] = {}
        # Map user_id -> WebSocket (for direct messaging)
        self.user_connections: Dict[str, WebSocket] = {}

    async def connect(self, websocket: WebSocket, session_code: str, user_id: str):
        # ✅ DO NOT accept here - already accepted in endpoint
        # Connection is already established when this method is called
        
        if session_code not in self.active_connections:
            self.active_connections[session_code] = []
        
        self.active_connections[session_code].append(websocket)
        self.user_connections[user_id] = websocket
        
        logger.info(f"User {user_id} connected to session {session_code}")

    def disconnect(self, websocket: WebSocket, session_code: str, user_id: str):
        if session_code in self.active_connections:
            if websocket in self.active_connections[session_code]:
                self.active_connections[session_code].remove(websocket)
                if not self.active_connections[session_code]:
                    del self.active_connections[session_code]
        
        if user_id in self.user_connections:
            del self.user_connections[user_id]
            
        logger.info(f"User {user_id} disconnected from session {session_code}")

    async def send_personal_message(self, message: dict, websocket: WebSocket):
        try:
            await websocket.send_json(message)
        except Exception as e:
            logger.error(f"Error sending personal message: {e}")

    async def broadcast_to_session(self, message: dict, session_code: str):
        if session_code in self.active_connections:
            for connection in self.active_connections[session_code]:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    logger.error(f"Error broadcasting to session {session_code}: {e}")

    async def broadcast_except(self, message: dict, session_code: str, exclude_user_id: str):
        if session_code in self.active_connections:
            exclude_ws = self.user_connections.get(exclude_user_id)
            for connection in self.active_connections[session_code]:
                if connection != exclude_ws:
                    try:
                        await connection.send_json(message)
                    except Exception as e:
                        logger.error(f"Error broadcasting (except) to session {session_code}: {e}")


manager = ConnectionManager()
