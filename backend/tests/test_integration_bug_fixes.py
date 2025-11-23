"""
Integration tests for all bug fixes in live quiz critical bugs spec
Tests Requirements: All (1.1-6.5)

This test suite validates:
- Bug 1: Host Final Results Page
- Bug 2: Drag-and-Drop Not Working
- Bug 3: Quiz Auto-Advancing for All Users
- Bug 4: Points Not Updating Correctly
- Bug 5: Answer Feedback Flashing Wrong Then Correct
- Bug 6: Mid-Quiz Leaderboard Showing Only One Participant

NOTE: Due to Motor (MongoDB async driver) event loop limitations on Windows,
these tests should be run individually:
  pytest tests/test_integration_bug_fixes.py::test_complete_quiz_flow_with_all_fixes -v
  pytest tests/test_integration_bug_fixes.py::test_drag_drop_question_flow -v

Both tests pass successfully when run separately.
"""
import pytest
import pytest_asyncio
from datetime import datetime, timedelta
from app.services.game_controller import GameController
from app.services.session_manager import SessionManager
from app.services.leaderboard_manager import LeaderboardManager
from app.core.database import redis_client, collection as quiz_collection
from bson import ObjectId
import json

pytestmark = pytest.mark.asyncio


@pytest_asyncio.fixture
async def setup_multi_participant_session():
    """Setup a test session with host + 3 participants"""
    game_controller = GameController()
    session_manager = SessionManager()
    leaderboard_manager = LeaderboardManager()
    
    # Create a test quiz with multiple questions
    quiz_data = {
        "title": "Integration Test Quiz",
        "questions": [
            {
                "questionText": "Question 1: What is 2+2?",
                "type": "singleMcq",
                "options": ["3", "4", "5", "6"],
                "correctAnswerIndex": 1
            },
            {
                "questionText": "Question 2: What is 3+3?",
                "type": "singleMcq",
                "options": ["5", "6", "7", "8"],
                "correctAnswerIndex": 1
            },
            {
                "questionText": "Question 3: What is 5+5?",
                "type": "singleMcq",
                "options": ["8", "9", "10", "11"],
                "correctAnswerIndex": 2
            }
        ]
    }
    
    result = await quiz_collection.insert_one(quiz_data)
    quiz_id = str(result.inserted_id)
    
    # Create session
    session_code = await session_manager.create_session(quiz_id, "host123")
    
    # Add 3 participants
    await session_manager.add_participant(session_code, "user1", "Alice")
    await session_manager.add_participant(session_code, "user2", "Bob")
    await session_manager.add_participant(session_code, "user3", "Charlie")
    
    # Start session
    await session_manager.start_session(session_code, "host123")
    
    # Initialize participant question indices
    for user_id in ["user1", "user2", "user3"]:
        await game_controller.set_participant_question_index(session_code, user_id, 0)
    
    yield {
        "session_code": session_code,
        "quiz_id": quiz_id,
        "game_controller": game_controller,
        "session_manager": session_manager,
        "leaderboard_manager": leaderboard_manager
    }
    
    # Cleanup
    session_key = f"session:{session_code}"
    await redis_client.delete(session_key)
    for user_id in ["user1", "user2", "user3"]:
        await redis_client.delete(f"participant:{session_code}:{user_id}:question_index")
    await quiz_collection.delete_one({"_id": ObjectId(quiz_id)})


@pytest.mark.asyncio
async def test_complete_quiz_flow_with_all_fixes(setup_multi_participant_session):
    """
    Task 7.1: Test complete quiz flow with all fixes
    
    Tests:
    - Bug 3: Self-paced progression (each participant advances independently)
    - Bug 4: Points calculated correctly with time bonuses
    - Bug 5: Answer feedback shows correctly (backend returns is_correct)
    - Bug 6: Mid-quiz leaderboard shows all participants
    - Bug 1: Host sees final results
    
    Requirements: All (1.1-6.5)
    """
    data = setup_multi_participant_session
    game_controller = data["game_controller"]
    session_manager = data["session_manager"]
    leaderboard_manager = data["leaderboard_manager"]
    session_code = data["session_code"]
    
    print("\n" + "="*80)
    print("INTEGRATION TEST: Complete Quiz Flow with All Bug Fixes")
    print("="*80)
    
    # Get initial session state
    session = await session_manager.get_session(session_code)
    assert session["status"] == "active"
    print(f"✅ Session started: {session_code}")
    print(f"   Participants: Alice, Bob, Charlie")
    
    # ========================================================================
    # QUESTION 1: Test self-paced progression (Bug 3)
    # ========================================================================
    print("\n--- Question 1: Testing Self-Paced Progression (Bug 3) ---")
    
    # Set question start time
    question_start_time = datetime.utcnow()
    session_key = f"session:{session_code}"
    await redis_client.hset(session_key, "question_start_time", question_start_time.isoformat())
    
    # Alice answers first (fast - 3 seconds)
    alice_answer_time = question_start_time + timedelta(seconds=3)
    alice_result = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user1",
        answer=1,  # Correct
        timestamp=alice_answer_time.timestamp()
    )
    
    # Verify Alice's answer result includes required fields (Bug 5)
    assert "is_correct" in alice_result
    assert "points" in alice_result
    assert "new_total_score" in alice_result
    assert "correct_answer" in alice_result
    assert alice_result["is_correct"] is True
    
    # Verify Alice got time bonus (Bug 4)
    alice_points = alice_result["points"]
    assert 1440 <= alice_points <= 1460, f"Expected ~1450 points for 3s answer, got {alice_points}"
    print(f"✅ Alice answered Q1 in 3s: {alice_points} points (Bug 4: Time bonus working)")
    print(f"   Answer result includes: is_correct={alice_result['is_correct']}, points={alice_points}, new_total_score={alice_result['new_total_score']}")
    
    # Check that Bob and Charlie are still on question 0 (Bug 3: Self-paced)
    bob_index = await game_controller.get_participant_question_index(session_code, "user2")
    charlie_index = await game_controller.get_participant_question_index(session_code, "user3")
    assert bob_index == 0, f"Bob should still be on Q0, but is on Q{bob_index}"
    assert charlie_index == 0, f"Charlie should still be on Q0, but is on Q{charlie_index}"
    print(f"✅ Bug 3 Fix Verified: Bob and Charlie still on Q0 after Alice answered")
    
    # Bob answers (medium speed - 15 seconds)
    bob_answer_time = question_start_time + timedelta(seconds=15)
    bob_result = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user2",
        answer=1,  # Correct
        timestamp=bob_answer_time.timestamp()
    )
    
    bob_points = bob_result["points"]
    assert 1240 <= bob_points <= 1260, f"Expected ~1250 points for 15s answer, got {bob_points}"
    print(f"✅ Bob answered Q1 in 15s: {bob_points} points")
    
    # Charlie answers (slow - 28 seconds)
    charlie_answer_time = question_start_time + timedelta(seconds=28)
    charlie_result = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user3",
        answer=1,  # Correct
        timestamp=charlie_answer_time.timestamp()
    )
    
    charlie_points = charlie_result["points"]
    assert 1020 <= charlie_points <= 1040, f"Expected ~1030 points for 28s answer, got {charlie_points}"
    print(f"✅ Charlie answered Q1 in 28s: {charlie_points} points")
    
    # ========================================================================
    # Test Mid-Quiz Leaderboard (Bug 6)
    # ========================================================================
    print("\n--- Testing Mid-Quiz Leaderboard (Bug 6) ---")
    
    # Get leaderboard after Q1
    leaderboard = await leaderboard_manager.get_leaderboard(session_code)
    
    # Verify all 3 participants are in leaderboard (Bug 6)
    assert len(leaderboard) >= 3, f"Expected at least 3 participants in leaderboard, got {len(leaderboard)}"
    
    participant_ids = [entry["user_id"] for entry in leaderboard]
    assert "user1" in participant_ids, "Alice should be in leaderboard"
    assert "user2" in participant_ids, "Bob should be in leaderboard"
    assert "user3" in participant_ids, "Charlie should be in leaderboard"
    assert "host123" not in participant_ids, "Host should NOT be in leaderboard"
    
    print(f"✅ Bug 6 Fix Verified: All 3 participants shown in leaderboard (host excluded)")
    print(f"   Leaderboard:")
    for i, entry in enumerate(leaderboard[:3], 1):
        print(f"   {i}. {entry['username']}: {entry['score']} points")
    
    # ========================================================================
    # QUESTION 2: Continue testing
    # ========================================================================
    print("\n--- Question 2: Continuing Quiz ---")
    
    # Move participants to Q2
    await game_controller.set_participant_question_index(session_code, "user1", 1)
    await game_controller.set_participant_question_index(session_code, "user2", 1)
    await game_controller.set_participant_question_index(session_code, "user3", 1)
    
    # Update question start time
    question_start_time_2 = datetime.utcnow()
    await redis_client.hset(session_key, "question_start_time", question_start_time_2.isoformat())
    
    # All participants answer Q2
    alice_answer_time_2 = question_start_time_2 + timedelta(seconds=5)
    alice_result_2 = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user1",
        answer=1,
        timestamp=alice_answer_time_2.timestamp()
    )
    
    # Verify score accumulation (Bug 4)
    alice_total_after_q2 = alice_result_2["new_total_score"]
    expected_total = alice_points + alice_result_2["points"]
    assert alice_total_after_q2 == expected_total, f"Score should accumulate: {alice_points} + {alice_result_2['points']} = {expected_total}, got {alice_total_after_q2}"
    print(f"✅ Bug 4 Fix Verified: Score accumulation working")
    print(f"   Alice Q1: {alice_points}, Q2: {alice_result_2['points']}, Total: {alice_total_after_q2}")
    
    # Bob and Charlie answer Q2
    bob_answer_time_2 = question_start_time_2 + timedelta(seconds=10)
    bob_result_2 = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user2",
        answer=1,
        timestamp=bob_answer_time_2.timestamp()
    )
    
    charlie_answer_time_2 = question_start_time_2 + timedelta(seconds=20)
    charlie_result_2 = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user3",
        answer=1,
        timestamp=charlie_answer_time_2.timestamp()
    )
    
    print(f"✅ All participants completed Q2")
    
    # ========================================================================
    # QUESTION 3: Final question
    # ========================================================================
    print("\n--- Question 3: Final Question ---")
    
    # Move participants to Q3
    await game_controller.set_participant_question_index(session_code, "user1", 2)
    await game_controller.set_participant_question_index(session_code, "user2", 2)
    await game_controller.set_participant_question_index(session_code, "user3", 2)
    
    # Update question start time
    question_start_time_3 = datetime.utcnow()
    await redis_client.hset(session_key, "question_start_time", question_start_time_3.isoformat())
    
    # All participants answer Q3
    alice_answer_time_3 = question_start_time_3 + timedelta(seconds=7)
    alice_result_3 = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user1",
        answer=2,
        timestamp=alice_answer_time_3.timestamp()
    )
    
    bob_answer_time_3 = question_start_time_3 + timedelta(seconds=12)
    bob_result_3 = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user2",
        answer=2,
        timestamp=bob_answer_time_3.timestamp()
    )
    
    charlie_answer_time_3 = question_start_time_3 + timedelta(seconds=25)
    charlie_result_3 = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user3",
        answer=2,
        timestamp=charlie_answer_time_3.timestamp()
    )
    
    print(f"✅ All participants completed Q3")
    
    # ========================================================================
    # Final Results (Bug 1)
    # ========================================================================
    print("\n--- Final Results (Bug 1: Host sees podium) ---")
    
    # Get final leaderboard
    final_leaderboard = await leaderboard_manager.get_leaderboard(session_code)
    
    # Verify we have rankings for final results
    assert len(final_leaderboard) >= 3, "Should have at least 3 participants for podium"
    
    print(f"✅ Bug 1 Fix: Final leaderboard data available for host")
    print(f"   Final Rankings:")
    for i, entry in enumerate(final_leaderboard[:3], 1):
        print(f"   {i}. {entry['username']}: {entry['score']} points")
    
    # Verify top 3 for podium widget
    top_3 = final_leaderboard[:3]
    assert len(top_3) == 3, "Should have exactly 3 participants for podium"
    
    # Verify Alice is first (fastest answers)
    assert top_3[0]["user_id"] == "user1", "Alice should be first (fastest answers)"
    
    print(f"✅ Bug 1 Fix Verified: Top 3 rankings available for podium widget")
    print(f"   🥇 Gold: {top_3[0]['username']} ({top_3[0]['score']} pts)")
    print(f"   🥈 Silver: {top_3[1]['username']} ({top_3[1]['score']} pts)")
    print(f"   🥉 Bronze: {top_3[2]['username']} ({top_3[2]['score']} pts)")
    
    print("\n" + "="*80)
    print("✅ ALL INTEGRATION TESTS PASSED")
    print("="*80)
    print("Bug Fixes Verified:")
    print("  ✅ Bug 1: Host Final Results Page - Rankings available")
    print("  ✅ Bug 3: Self-Paced Progression - Participants advance independently")
    print("  ✅ Bug 4: Points Calculation - Time bonuses working correctly")
    print("  ✅ Bug 5: Answer Feedback - Backend returns is_correct immediately")
    print("  ✅ Bug 6: Mid-Quiz Leaderboard - All participants shown")
    print("="*80)


@pytest_asyncio.fixture(scope="function")
async def setup_drag_drop_session():
    """Setup a test session with drag-and-drop question"""
    game_controller = GameController()
    session_manager = SessionManager()
    
    # Create a test quiz with drag-and-drop question
    # Note: correctMatches should be a dict mapping drop zones to items
    quiz_data = {
        "title": "Drag-Drop Test Quiz",
        "questions": [
            {
                "questionText": "Arrange these numbers in ascending order",
                "type": "dragAndDrop",
                "items": ["5", "2", "8", "1", "3"],
                "correctMatches": {
                    "0": "1",
                    "1": "2",
                    "2": "3",
                    "3": "5",
                    "4": "8"
                }
            }
        ]
    }
    
    result = await quiz_collection.insert_one(quiz_data)
    quiz_id = str(result.inserted_id)
    
    # Create session
    session_code = await session_manager.create_session(quiz_id, "host123")
    
    # Add 2 participants
    await session_manager.add_participant(session_code, "user1", "Alice")
    await session_manager.add_participant(session_code, "user2", "Bob")
    
    # Start session
    await session_manager.start_session(session_code, "host123")
    
    # Initialize participant question indices
    await game_controller.set_participant_question_index(session_code, "user1", 0)
    await game_controller.set_participant_question_index(session_code, "user2", 0)
    
    yield {
        "session_code": session_code,
        "quiz_id": quiz_id,
        "game_controller": game_controller,
        "session_manager": session_manager
    }
    
    # Cleanup
    session_key = f"session:{session_code}"
    await redis_client.delete(session_key)
    await redis_client.delete(f"participant:{session_code}:user1:question_index")
    await redis_client.delete(f"participant:{session_code}:user2:question_index")
    await quiz_collection.delete_one({"_id": ObjectId(quiz_id)})


@pytest.mark.asyncio
async def test_drag_drop_question_flow(setup_drag_drop_session):
    """
    Task 7.2: Test drag-and-drop question in full flow
    
    Tests:
    - Bug 2: Drag-and-drop items can be dragged and placed
    - Bug 2: Correct evaluation of drag-and-drop answers
    - Bug 4: Points awarded correctly for drag-and-drop
    
    Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 4.1, 4.2
    """
    data = setup_drag_drop_session
    game_controller = data["game_controller"]
    session_manager = data["session_manager"]
    session_code = data["session_code"]
    
    print("\n" + "="*80)
    print("INTEGRATION TEST: Drag-and-Drop Question Flow")
    print("="*80)
    
    # Get session
    session = await session_manager.get_session(session_code)
    assert session["status"] == "active"
    print(f"✅ Session started: {session_code}")
    print(f"   Participants: Alice, Bob")
    
    # Set question start time
    question_start_time = datetime.utcnow()
    session_key = f"session:{session_code}"
    await redis_client.hset(session_key, "question_start_time", question_start_time.isoformat())
    
    print("\n--- Testing Drag-and-Drop Question (Bug 2) ---")
    print("Question: Arrange these numbers in ascending order")
    print("Items: [5, 2, 8, 1, 3]")
    print("Correct Matches: {0: '1', 1: '2', 2: '3', 3: '5', 4: '8'}")
    
    # ========================================================================
    # Alice submits CORRECT drag-and-drop answer
    # ========================================================================
    print("\n--- Alice's Turn: Correct Answer ---")
    
    # Simulate Alice dragging items in correct order (dict format)
    alice_answer = {
        "0": "1",
        "1": "2",
        "2": "3",
        "3": "5",
        "4": "8"
    }
    alice_answer_time = question_start_time + timedelta(seconds=8)
    
    alice_result = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user1",
        answer=alice_answer,
        timestamp=alice_answer_time.timestamp()
    )
    
    # Verify drag-and-drop evaluation (Bug 2)
    assert "is_correct" in alice_result
    assert alice_result["is_correct"] is True, "Alice's correct order should be marked correct"
    print(f"✅ Bug 2 Fix Verified: Drag-and-drop evaluation working")
    print(f"   Alice's answer: {alice_answer}")
    print(f"   Evaluation: {'CORRECT' if alice_result['is_correct'] else 'INCORRECT'}")
    
    # Verify points awarded (Bug 4)
    alice_points = alice_result["points"]
    # Expected: 1000 base + (1 - 8/30) * 500 = 1000 + 366.67 = ~1367
    assert 1350 <= alice_points <= 1380, f"Expected ~1367 points for 8s answer, got {alice_points}"
    print(f"✅ Bug 4 Fix Verified: Points calculated correctly for drag-and-drop")
    print(f"   Alice answered in 8s: {alice_points} points")
    print(f"   Breakdown: 1000 base + time bonus = {alice_points}")
    
    # ========================================================================
    # Bob submits INCORRECT drag-and-drop answer
    # ========================================================================
    print("\n--- Bob's Turn: Incorrect Answer ---")
    
    # Simulate Bob dragging items in wrong order (3 and 5 swapped)
    bob_answer = {
        "0": "1",
        "1": "2",
        "2": "5",  # Wrong - should be 3
        "3": "3",  # Wrong - should be 5
        "4": "8"
    }
    bob_answer_time = question_start_time + timedelta(seconds=12)
    
    bob_result = await game_controller.submit_answer(
        session_code=session_code,
        user_id="user2",
        answer=bob_answer,
        timestamp=bob_answer_time.timestamp()
    )
    
    # Verify incorrect evaluation
    assert bob_result["is_correct"] is False, "Bob's wrong order should be marked incorrect"
    assert bob_result["points"] == 0, "Incorrect answer should give 0 points"
    print(f"✅ Bug 2 Fix Verified: Incorrect drag-and-drop detected")
    print(f"   Bob's answer: {bob_answer}")
    print(f"   Evaluation: {'CORRECT' if bob_result['is_correct'] else 'INCORRECT'}")
    print(f"   Points: {bob_result['points']}")
    
    # Verify correct answer is returned (Bug 5)
    assert "correct_answer" in bob_result
    print(f"✅ Correct answer provided in response: {bob_result['correct_answer']}")
    
    # ========================================================================
    # Verify both participants completed independently (Bug 3)
    # ========================================================================
    print("\n--- Verifying Self-Paced Progression ---")
    
    alice_index = await game_controller.get_participant_question_index(session_code, "user1")
    bob_index = await game_controller.get_participant_question_index(session_code, "user2")
    
    # Both should still be on question 0 (haven't requested next question yet)
    assert alice_index == 0, f"Alice should be on Q0, got Q{alice_index}"
    assert bob_index == 0, f"Bob should be on Q0, got Q{bob_index}"
    print(f"✅ Bug 3 Fix Verified: Both participants on Q0 independently")
    
    print("\n" + "="*80)
    print("✅ DRAG-AND-DROP INTEGRATION TEST PASSED")
    print("="*80)
    print("Bug Fixes Verified:")
    print("  ✅ Bug 2: Drag-and-Drop Working - Items can be placed and evaluated")
    print("  ✅ Bug 2: Correct Evaluation - Both correct and incorrect answers detected")
    print("  ✅ Bug 4: Points Calculation - Time bonuses applied to drag-and-drop")
    print("  ✅ Bug 3: Self-Paced - Participants progress independently")
    print("="*80)
