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
        # Map session_code -> {user_id -> isHost}
        self.connection_roles: Dict[str, Dict[str, bool]] = {}

    async def connect(self, websocket: WebSocket, session_code: str, user_id: str, is_host: bool = False):
        # ✅ DO NOT accept here - already accepted in endpoint
        # Connection is already established when this method is called
        
        if session_code not in self.active_connections:
            self.active_connections[session_code] = []
        
        if session_code not in self.connection_roles:
            self.connection_roles[session_code] = {}
        
        self.active_connections[session_code].append(websocket)
        self.user_connections[user_id] = websocket
        self.connection_roles[session_code][user_id] = is_host
        
        logger.info(f"User {user_id} connected to session {session_code} (host={is_host})")

    def disconnect(self, websocket: WebSocket, session_code: str, user_id: str):
        if session_code in self.active_connections:
            if websocket in self.active_connections[session_code]:
                self.active_connections[session_code].remove(websocket)
                if not self.active_connections[session_code]:
                    del self.active_connections[session_code]
        
        if session_code in self.connection_roles:
            if user_id in self.connection_roles[session_code]:
                del self.connection_roles[session_code][user_id]
            
            # Clean up empty role tracking
            if not self.connection_roles[session_code]:
                del self.connection_roles[session_code]
        
        if user_id in self.user_connections:
            del self.user_connections[user_id]
            
        logger.info(f"User {user_id} disconnected from session {session_code}")

    async def send_personal_message(self, message: dict, websocket: WebSocket = None, session_code: str = None, user_id: str = None):
        """Send message to a specific user. Can use either websocket directly or session_code + user_id"""
        if websocket is None:
            # Look up websocket by user_id
            if user_id and user_id in self.user_connections:
                websocket = self.user_connections[user_id]
            else:
                logger.warning(f"Cannot send personal message: user {user_id} not found")
                return
        
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
    
    async def broadcast_to_host(self, message: dict, session_code: str, host_id: str):
        """Send message specifically to the host"""
        host_ws = self.user_connections.get(host_id)
        if host_ws:
            try:
                await host_ws.send_json(message)
            except Exception as e:
                logger.error(f"Error sending message to host {host_id}: {e}")
    
    async def broadcast_to_participants(self, message: dict, session_code: str):
        """Broadcast message to all participants (non-host users) in a session"""
        if session_code not in self.active_connections:
            return
        
        if session_code not in self.connection_roles:
            return
        
        # Get list of participant user_ids (non-hosts)
        participant_ids = [
            user_id for user_id, is_host in self.connection_roles[session_code].items()
            if not is_host
        ]
        
        for user_id in participant_ids:
            if user_id in self.user_connections:
                try:
                    await self.user_connections[user_id].send_json(message)
                except Exception as e:
                    logger.error(f"Error broadcasting to participant {user_id}: {e}")


manager = ConnectionManager()

