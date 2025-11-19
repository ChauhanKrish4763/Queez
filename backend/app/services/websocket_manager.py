from typing import Dict, Set
from fastapi import WebSocket
import json
import logging

logger = logging.getLogger(__name__)

class ConnectionManager:
    """Manages WebSocket connections for live multiplayer sessions"""
    
    def __init__(self):
        # session_code -> {user_id -> WebSocket}
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {}
        # user_id -> session_code (for reverse lookup)
        self.user_sessions: Dict[str, str] = {}
    
    async def connect(self, websocket: WebSocket, session_code: str, user_id: str):
        """Register a new WebSocket connection"""
        await websocket.accept()
        
        if session_code not in self.active_connections:
            self.active_connections[session_code] = {}
        
        self.active_connections[session_code][user_id] = websocket
        self.user_sessions[user_id] = session_code
        
        logger.info(f"User {user_id} connected to session {session_code}")
    
    async def disconnect(self, session_code: str, user_id: str):
        """Remove a WebSocket connection"""
        if session_code in self.active_connections:
            if user_id in self.active_connections[session_code]:
                del self.active_connections[session_code][user_id]
                logger.info(f"User {user_id} disconnected from session {session_code}")
            
            # Clean up empty sessions
            if not self.active_connections[session_code]:
                del self.active_connections[session_code]
        
        if user_id in self.user_sessions:
            del self.user_sessions[user_id]
    
    async def send_personal_message(self, message: dict, session_code: str, user_id: str):
        """Send message to a specific user"""
        if session_code in self.active_connections:
            if user_id in self.active_connections[session_code]:
                websocket = self.active_connections[session_code][user_id]
                try:
                    await websocket.send_json(message)
                except Exception as e:
                    logger.error(f"Error sending message to {user_id}: {e}")
                    await self.disconnect(session_code, user_id)
    
    async def broadcast_to_session(self, message: dict, session_code: str):
        """Broadcast message to all participants in a session"""
        if session_code not in self.active_connections:
            return
        
        disconnected_users = []
        for user_id, websocket in self.active_connections[session_code].items():
            try:
                await websocket.send_json(message)
            except Exception as e:
                logger.error(f"Error broadcasting to {user_id}: {e}")
                disconnected_users.append(user_id)
        
        # Clean up disconnected users
        for user_id in disconnected_users:
            await self.disconnect(session_code, user_id)
    
    async def broadcast_except(self, message: dict, session_code: str, exclude_user_id: str):
        """Broadcast to all participants except one"""
        if session_code not in self.active_connections:
            return
        
        disconnected_users = []
        for user_id, websocket in self.active_connections[session_code].items():
            if user_id == exclude_user_id:
                continue
            try:
                await websocket.send_json(message)
            except Exception as e:
                logger.error(f"Error broadcasting to {user_id}: {e}")
                disconnected_users.append(user_id)
        
        # Clean up disconnected users
        for user_id in disconnected_users:
            await self.disconnect(session_code, user_id)
    
    def get_session_participants(self, session_code: str) -> Set[str]:
        """Get all connected user IDs for a session"""
        if session_code in self.active_connections:
            return set(self.active_connections[session_code].keys())
        return set()
    
    def is_user_connected(self, session_code: str, user_id: str) -> bool:
        """Check if a user is connected to a session"""
        return (session_code in self.active_connections and 
                user_id in self.active_connections[session_code])

# Global instance
manager = ConnectionManager()
