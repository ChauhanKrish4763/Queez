import logging
from datetime import datetime
from typing import Dict, Any, Optional, List
import json

from app.core.database import redis_client, collection as quiz_collection
from app.core.config import QUESTION_TIME_SECONDS
from bson import ObjectId

logger = logging.getLogger(__name__)

class GameController:
    def __init__(self):
        self.redis = redis_client

    async def get_current_question(self, session_code: str) -> Optional[Dict[str, Any]]:
        """Get the current question for the session"""
        session_key = f"session:{session_code}"
        
        logger.info(f"📚 Getting current question for session {session_code}")
        
        # Get current index and quiz ID
        session_data = await self.redis.hmget(session_key, ["current_question_index", "quiz_id", "question_start_time"])
        logger.info(f"📊 Session data from Redis: index={session_data[0]}, quiz_id={session_data[1]}")
        
        if not all(session_data[:2]): # Check if index and quiz_id exist
            logger.error(f"❌ Missing session data! index={session_data[0]}, quiz_id={session_data[1]}")
            return None
            
        current_index = int(session_data[0])
        quiz_id = session_data[1]
        start_time = session_data[2]
        
        # Fetch quiz from MongoDB (could be cached in Redis for performance)
        logger.info(f"🔍 Fetching quiz from MongoDB with ID: {quiz_id}")
        quiz = await quiz_collection.find_one({"_id": ObjectId(quiz_id)})
        
        if not quiz:
            logger.error(f"❌ Quiz not found in MongoDB with ID: {quiz_id}")
            return None
            
        if "questions" not in quiz:
            logger.error(f"❌ Quiz {quiz_id} has no questions field!")
            return None
            
        logger.info(f"✅ Quiz loaded successfully. Total questions: {len(quiz['questions'])}")
            
        questions = quiz["questions"]
        if current_index >= len(questions):
            logger.warning(f"⚠️ Question index {current_index} out of range (total: {len(questions)})")
            return None
            
        question = questions[current_index]
        
        # Ensure question has required fields
        question_text = question.get('questionText', question.get('question', ''))
        question_type = question.get('type', 'single')
        
        # Validate question text is not empty
        if not question_text or not question_text.strip():
            logger.error(f"❌ Question {current_index} has empty question text!")
            return None
        
        logger.info(f"✅ Retrieved question {current_index + 1}/{len(questions)}: {question_text[:50]}...")
        
        # Calculate time remaining
        time_remaining = QUESTION_TIME_SECONDS
        if start_time:
            elapsed = (datetime.utcnow() - datetime.fromisoformat(start_time)).total_seconds()
            time_remaining = max(0, QUESTION_TIME_SECONDS - int(elapsed))
        
        # Build question payload with normalized field names
        question_payload = {
            "question": question_text,
            "questionType": question_type,
            "type": question_type,  # Keep for backward compatibility
            "options": question.get('options', []),
            "id": question.get('id', str(current_index)),
        }
        
        # Include optional fields if present
        if 'correctAnswerIndex' in question:
            question_payload['correctAnswerIndex'] = question['correctAnswerIndex']
        if 'correctAnswerIndices' in question:
            question_payload['correctAnswerIndices'] = question['correctAnswerIndices']
        if 'dragItems' in question:
            question_payload['dragItems'] = question['dragItems']
        if 'dropTargets' in question:
            question_payload['dropTargets'] = question['dropTargets']
        if 'correctMatches' in question:
            question_payload['correctMatches'] = question['correctMatches']
        if 'imageUrl' in question:
            question_payload['imageUrl'] = question['imageUrl']
            
        return {
            "question": question_payload,
            "index": current_index,
            "total": len(questions),
            "time_remaining": time_remaining
        }

    async def submit_answer(self, session_code: str, user_id: str, answer: Any, timestamp: float) -> Dict[str, Any]:
        """Process a participant's answer"""
        session_key = f"session:{session_code}"
        
        # Get session state
        session_data = await self.redis.hmget(session_key, ["current_question_index", "quiz_id", "question_start_time", "participants"])
        current_index = int(session_data[0])
        quiz_id = session_data[1]
        start_time_str = session_data[2]
        participants_json = session_data[3]
        
        if not start_time_str:
             return {"error": "Question not active"}

        # Validate time
        start_time = datetime.fromisoformat(start_time_str)
        elapsed = (datetime.utcnow() - start_time).total_seconds()
        
        if elapsed > QUESTION_TIME_SECONDS + 2: # 2 seconds grace period for latency
            return {"error": "Time expired", "is_correct": False, "points": 0}

        # Get correct answer
        quiz = await quiz_collection.find_one({"_id": ObjectId(quiz_id)})
        question = quiz["questions"][current_index]
        correct_answer = question.get("correct_answer") # Index or value depending on question type
        
        # Check correctness
        # Assuming multiple choice where answer is an index (int) or string
        is_correct = str(answer) == str(correct_answer)
        
        # Calculate points
        points = 0
        if is_correct:
            base_points = 1000
            time_bonus = int(max(0, (1 - elapsed / QUESTION_TIME_SECONDS) * 500))
            points = base_points + time_bonus
            
        # Update participant data
        participants = json.loads(participants_json)
        if user_id in participants:
            participant = participants[user_id]
            
            # Check if already answered
            for ans in participant["answers"]:
                if ans["question_index"] == current_index:
                    return {"error": "Already answered"}
            
            # Record answer
            participant["answers"].append({
                "question_index": current_index,
                "answer": answer,
                "timestamp": timestamp,
                "is_correct": is_correct,
                "points_earned": points
            })
            participant["score"] += points
            
            # Save back to Redis
            await self.redis.hset(session_key, "participants", json.dumps(participants))
            
            return {
                "is_correct": is_correct,
                "points": points,
                "correct_answer": correct_answer,
                "new_total_score": participant["score"]
            }
            
        return {"error": "Participant not found"}

    async def advance_question(self, session_code: str) -> bool:
        """Move to the next question"""
        session_key = f"session:{session_code}"
        
        # Increment index
        current_index = await self.redis.hincrby(session_key, "current_question_index", 1)
        
        # Reset start time
        await self.redis.hset(session_key, "question_start_time", datetime.utcnow().isoformat())
        
        return True
        
    async def start_question_timer(self, session_code: str):
        """Start the timer for the current question"""
        session_key = f"session:{session_code}"
        await self.redis.hset(session_key, "question_start_time", datetime.utcnow().isoformat())

    async def check_all_answered(self, session_code: str) -> bool:
        """Check if all connected participants have answered the current question"""
        session_key = f"session:{session_code}"
        session_data = await self.redis.hmget(session_key, ["current_question_index", "participants"])
        current_index = int(session_data[0])
        participants = json.loads(session_data[1])
        
        for p in participants.values():
            if p.get("connected", False):
                has_answered = any(a["question_index"] == current_index for a in p["answers"])
                if not has_answered:
                    return False
        return True

    async def get_answer_distribution(self, session_code: str) -> Dict[str, int]:
        """Calculate answer distribution statistics for current question"""
        session_key = f"session:{session_code}"
        session_data = await self.redis.hmget(session_key, ["current_question_index", "participants"])
        current_index = int(session_data[0])
        participants = json.loads(session_data[1])
        
        distribution = {}
        for p in participants.values():
            for ans in p["answers"]:
                if ans["question_index"] == current_index:
                    answer_key = str(ans["answer"])
                    distribution[answer_key] = distribution.get(answer_key, 0) + 1
        
        return distribution

    async def calculate_accuracy(self, session_code: str, user_id: str) -> float:
        """Calculate accuracy percentage for a participant"""
        session_key = f"session:{session_code}"
        participants_json = await self.redis.hget(session_key, "participants")
        participants = json.loads(participants_json)
        
        if user_id not in participants:
            return 0.0
        
        participant = participants[user_id]
        answers = participant.get("answers", [])
        
        if not answers:
            return 0.0
        
        correct_count = sum(1 for ans in answers if ans.get("is_correct", False))
        return (correct_count / len(answers)) * 100
