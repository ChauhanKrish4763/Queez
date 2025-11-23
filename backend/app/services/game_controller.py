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
        
        # Get participant's current question index
        current_index = await self.get_participant_question_index(session_code, user_id)
        
        logger.info(f"📝 Processing answer for user {user_id} on question {current_index}")
        
        # Get session state
        session_data = await self.redis.hmget(session_key, ["quiz_id", "participants"])
        quiz_id = session_data[0]
        participants_json = session_data[1]
        
        if not quiz_id:
            return {"error": "Session not found"}

        # Get correct answer
        quiz = await quiz_collection.find_one({"_id": ObjectId(quiz_id)})
        
        if not quiz or "questions" not in quiz:
            return {"error": "Quiz not found"}
        
        if current_index >= len(quiz["questions"]):
            return {"error": "Invalid question index"}
        
        question = quiz["questions"][current_index]
        question_type = question.get("type", "singleMcq")
        
        logger.info(f"📝 Question type: {question_type}")
        
        # Handle different question types
        is_correct = False
        
        if question_type in ["singleMcq", "trueFalse"]:
            # Single answer questions
            correct_answer = question.get("correctAnswerIndex")
            if correct_answer is None:
                logger.error(f"❌ No correct answer found for question {current_index}")
                return {"error": "Invalid question configuration"}
            
            is_correct = int(answer) == int(correct_answer)
            logger.info(f"🎯 Single answer check: user={user_id}, answer={answer}, correct={correct_answer}, is_correct={is_correct}")
            
        elif question_type == "multiMcq":
            # Multiple answer questions
            correct_answers = question.get("correctAnswerIndices", [])
            if not correct_answers:
                logger.error(f"❌ No correct answers found for multi-choice question {current_index}")
                return {"error": "Invalid question configuration"}
            
            # Answer should be a list of indices
            user_answers = answer if isinstance(answer, list) else [answer]
            user_answers_set = set(int(a) for a in user_answers)
            correct_answers_set = set(int(a) for a in correct_answers)
            
            is_correct = user_answers_set == correct_answers_set
            logger.info(f"🎯 Multi answer check: user={user_id}, answers={user_answers_set}, correct={correct_answers_set}, is_correct={is_correct}")
            
        elif question_type == "dragAndDrop":
            # Drag and drop questions
            correct_matches = question.get("correctMatches", {})
            if not correct_matches:
                logger.error(f"❌ No correct matches found for drag-drop question {current_index}")
                return {"error": "Invalid question configuration"}
            
            # Answer should be a dict/object of matches
            user_matches = answer if isinstance(answer, dict) else {}
            is_correct = user_matches == correct_matches
            logger.info(f"🎯 Drag-drop check: user={user_id}, matches={user_matches}, correct={correct_matches}, is_correct={is_correct}")
        
        else:
            logger.error(f"❌ Unknown question type: {question_type}")
            return {"error": "Unknown question type"}
        
        # Calculate points (time-based scoring)
        points = 0
        if is_correct:
            base_points = 1000
            # Use timestamp if provided, otherwise no time bonus
            time_bonus = 0
            if timestamp:
                # Assume 30 seconds per question
                elapsed = min(timestamp, QUESTION_TIME_SECONDS)
                time_bonus = int(max(0, (1 - elapsed / QUESTION_TIME_SECONDS) * 500))
            points = base_points + time_bonus
            logger.info(f"✅ Correct answer! Base: {base_points}, Time bonus: {time_bonus}, Total: {points}")
        
        # Update participant data
        participants = json.loads(participants_json)
        if user_id in participants:
            participant = participants[user_id]
            
            # Check if already answered
            for ans in participant["answers"]:
                if ans["question_index"] == current_index:
                    logger.warning(f"⚠️ User {user_id} already answered question {current_index}")
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
            
            logger.info(f"💾 Saved answer for {user_id}: score now {participant['score']}")
            
            # Return correct answer based on question type
            correct_answer_response = None
            if question_type in ["singleMcq", "trueFalse"]:
                correct_answer_response = str(question.get("correctAnswerIndex"))
            elif question_type == "multiMcq":
                correct_answer_response = question.get("correctAnswerIndices", [])
            elif question_type == "dragAndDrop":
                correct_answer_response = question.get("correctMatches", {})
            
            return {
                "is_correct": is_correct,
                "points": points,
                "correct_answer": correct_answer_response,
                "new_total_score": participant["score"],
                "question_type": question_type
            }
            
        logger.error(f"❌ Participant {user_id} not found in session")
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

    async def get_participant_question_index(self, session_code: str, user_id: str) -> int:
        """Get the current question index for a specific participant"""
        session_key = f"session:{session_code}"
        participant_key = f"participant:{session_code}:{user_id}:question_index"
        
        # Try to get from Redis first
        index = await self.redis.get(participant_key)
        
        if index is not None:
            logger.info(f"📊 PROGRESS - Found cached index for {user_id}: {int(index)}")
            return int(index)
        
        # If not found, check their answers to determine progress
        logger.info(f"🔍 PROGRESS - No cached index for {user_id}, checking answers")
        participants_json = await self.redis.hget(session_key, "participants")
        if participants_json:
            participants = json.loads(participants_json)
            if user_id in participants:
                answers = participants[user_id].get("answers", [])
                # Return the highest question index they've answered
                if answers:
                    max_index = max(ans["question_index"] for ans in answers)
                    logger.info(f"📊 PROGRESS - Calculated index from answers for {user_id}: {max_index}")
                    return max_index
        
        logger.info(f"📊 PROGRESS - No progress found for {user_id}, defaulting to 0")
        return 0  # Default to first question

    async def set_participant_question_index(self, session_code: str, user_id: str, index: int):
        """Set the current question index for a specific participant"""
        participant_key = f"participant:{session_code}:{user_id}:question_index"
        await self.redis.set(participant_key, index)
        logger.info(f"✅ PROGRESS - Set {user_id} question index to {index}")

    async def get_total_questions(self, session_code: str) -> int:
        """Get total number of questions in the quiz"""
        session_key = f"session:{session_code}"
        quiz_id = await self.redis.hget(session_key, "quiz_id")
        
        if not quiz_id:
            return 0
        
        quiz = await quiz_collection.find_one({"_id": ObjectId(quiz_id)})
        if not quiz or "questions" not in quiz:
            return 0
        
        return len(quiz["questions"])

    async def get_question_by_index(self, session_code: str, index: int) -> Optional[Dict[str, Any]]:
        """Get a specific question by index"""
        session_key = f"session:{session_code}"
        
        logger.info(f"📚 Getting question {index} for session {session_code}")
        
        # Get quiz ID
        quiz_id = await self.redis.hget(session_key, "quiz_id")
        
        if not quiz_id:
            logger.error(f"❌ Quiz ID not found for session {session_code}")
            return None
        
        # Fetch quiz from MongoDB
        quiz = await quiz_collection.find_one({"_id": ObjectId(quiz_id)})
        
        if not quiz or "questions" not in quiz:
            logger.error(f"❌ Quiz or questions not found")
            return None
        
        questions = quiz["questions"]
        
        if index >= len(questions):
            logger.warning(f"⚠️ Question index {index} out of range (total: {len(questions)})")
            return None
        
        question = questions[index]
        
        # Ensure question has required fields
        question_text = question.get('questionText', question.get('question', ''))
        question_type = question.get('type', 'single')
        
        if not question_text or not question_text.strip():
            logger.error(f"❌ Question {index} has empty question text!")
            return None
        
        logger.info(f"✅ Retrieved question {index + 1}/{len(questions)}: {question_text[:50]}...")
        
        # Build question payload
        question_payload = {
            "question": question_text,
            "questionType": question_type,
            "type": question_type,
            "options": question.get('options', []),
            "id": question.get('id', str(index)),
        }
        
        # Include optional fields
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
            "index": index,
            "total": len(questions),
            "time_remaining": QUESTION_TIME_SECONDS
        }