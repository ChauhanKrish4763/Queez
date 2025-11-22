"""
Comprehensive API Testing Script for Quiz App - Including Error Cases
Tests all endpoints with both success and failure scenarios
Run: python test_api_comprehensive.py
"""

import requests
import json
from typing import Dict, Optional
from datetime import datetime
import time

# Configuration
BASE_URL = "http://localhost:8000"
RESULTS = {"passed": 0, "failed": 0, "error_tests_passed": 0, "tests": []}

# Colors for terminal output
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    """Print a formatted header"""
    print(f"\n{Colors.CYAN}{Colors.BOLD}{'='*70}{Colors.RESET}")
    print(f"{Colors.CYAN}{Colors.BOLD}{text.center(70)}{Colors.RESET}")
    print(f"{Colors.CYAN}{Colors.BOLD}{'='*70}{Colors.RESET}\n")

def print_test(name, status, details="", response_data=None, is_error_test=False):
    """Print test result with detailed feedback"""
    if status == "PASS":
        symbol = "✓"
        color = Colors.GREEN
        RESULTS["passed"] += 1
        if is_error_test:
            RESULTS["error_tests_passed"] += 1
        status_text = "PASSED"
    else:
        symbol = "✗"
        color = Colors.RED
        RESULTS["failed"] += 1
        status_text = "FAILED"
    
    error_marker = f" {Colors.YELLOW}[ERROR TEST]{Colors.RESET}" if is_error_test else ""
    print(f"\n{color}{Colors.BOLD}[{symbol}] {name} - {status_text}{error_marker}{Colors.RESET}")
    
    if details:
        print(f"    {Colors.YELLOW}Status: {details}{Colors.RESET}")
    
    if response_data and isinstance(response_data, dict):
        print(f"    {Colors.CYAN}Response Summary:{Colors.RESET}")
        for key, value in list(response_data.items())[:5]:
            if isinstance(value, (str, int, float, bool)):
                print(f"      • {key}: {value}")
            elif isinstance(value, list):
                print(f"      • {key}: [{len(value)} items]")
            elif isinstance(value, dict):
                print(f"      • {key}: {{...}}")
    
    RESULTS["tests"].append({
        "name": name,
        "status": status,
        "details": details,
        "is_error_test": is_error_test
    })

def test_endpoint(method, endpoint, expected_status=200, data=None, name="", sleep_after=0.5, is_error_test=False):
    """Generic endpoint tester with enhanced feedback"""
    url = f"{BASE_URL}{endpoint}"
    
    print(f"\n{Colors.BLUE}{'─'*70}{Colors.RESET}")
    print(f"{Colors.BOLD}Testing: {name or f'{method} {endpoint}'}{Colors.RESET}")
    print(f"{Colors.MAGENTA}Endpoint: {method} {endpoint}{Colors.RESET}")
    
    response = None
    try:
        # Increased timeout for MongoDB Atlas connections
        if method == "GET":
            response = requests.get(url, timeout=15)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=15)
        elif method == "PUT":
            response = requests.put(url, json=data, timeout=15)
        elif method == "PATCH":
            response = requests.patch(url, json=data, timeout=15)
        elif method == "DELETE":
            response = requests.delete(url, timeout=15)
        
        response_data = response.json() if response.content else {}
        
        if response.status_code == expected_status:
            print_test(
                name or f"{method} {endpoint}", 
                "PASS", 
                f"HTTP {response.status_code} - Response received successfully",
                response_data,
                is_error_test
            )
            time.sleep(sleep_after)
            return response_data
        else:
            print_test(
                name or f"{method} {endpoint}", 
                "FAIL", 
                f"Expected HTTP {expected_status}, got {response.status_code}",
                response_data,
                is_error_test
            )
            time.sleep(sleep_after)
            return None
    
    except requests.exceptions.ConnectionError:
        print_test(
            name or f"{method} {endpoint}", 
            "FAIL", 
            "⚠️ Connection Error - Is the server running?",
            is_error_test=is_error_test
        )
        time.sleep(sleep_after)
        return None
    except requests.exceptions.Timeout:
        print_test(
            name or f"{method} {endpoint}", 
            "FAIL", 
            "⏱️ Request timed out after 15 seconds - Check MongoDB Atlas connection",
            is_error_test=is_error_test
        )
        time.sleep(sleep_after)
        return None
    except Exception as e:
        print_test(
            name or f"{method} {endpoint}", 
            "FAIL", 
            f"❌ Error: {str(e)}",
            is_error_test=is_error_test
        )
        time.sleep(sleep_after)
        return None


# ============================================
# SUCCESS TEST CASES
# ============================================

def test_1_health_check():
    """Test 1: Health Check"""
    print_header("TEST 1: HEALTH CHECK")
    response = test_endpoint("GET", "/", name="API Health Check", expected_status=200)
    return response is not None

def test_2_quiz_crud():
    """Test 2: Quiz CRUD Operations"""
    print_header("TEST 2: QUIZ CRUD OPERATIONS")
    
    # Create Quiz
    quiz_data = {
        "title": "Automated Test Quiz - Python Basics",
        "description": "Test quiz created by automated testing script",
        "language": "English",
        "category": "Science and Technology",
        "creatorId": "test_user_123",
        "questions": [
            {
                "id": "1",
                "questionText": "What is Python?",
                "type": "single",
                "options": ["Programming Language", "Snake", "Software", "OS"],
                "correctAnswerIndex": 0
            },
            {
                "id": "2",
                "questionText": "Is Python open source?",
                "type": "single",
                "options": ["True", "False"],
                "correctAnswerIndex": 0
            }
        ]
    }
    
    response = test_endpoint("POST", "/quizzes", data=quiz_data, name="Create Quiz", expected_status=200)
    
    if not response or "id" not in response:
        return None
    
    quiz_id = response["id"]
    
    # Get Quiz Library
    test_endpoint("GET", f"/quizzes/library/test_user_123", name="Get Quiz Library by User", expected_status=200)
    
    # Get Single Quiz
    test_endpoint("GET", f"/quizzes/{quiz_id}?user_id=test_user_123", name="Get Quiz by ID", expected_status=200)
    
    # Update Quiz (PUT)
    updated_quiz = quiz_data.copy()
    updated_quiz["title"] = "Updated - Automated Test Quiz"
    test_endpoint("PUT", f"/quizzes/{quiz_id}", data=updated_quiz, name="Update Quiz (PUT)", expected_status=200)
    
    # Partial Update (PATCH)
    test_endpoint("PATCH", f"/quizzes/{quiz_id}", data={"description": "Partially updated by test"}, name="Partial Update Quiz (PATCH)", expected_status=200)
    
    return quiz_id

def test_3_search_and_filter():
    """Test 3: Search and Filter"""
    print_header("TEST 3: SEARCH & FILTER")
    
    test_endpoint("GET", "/quizzes/search?q=python", name="Search Quizzes", expected_status=200)
    test_endpoint("GET", "/quizzes/category/Science and Technology", name="Filter by Category", expected_status=200)
    test_endpoint("GET", "/quizzes/language/English", name="Filter by Language", expected_status=200)
    test_endpoint("GET", "/quizzes/top-rated", name="Get Top Rated Quizzes", expected_status=200)

def test_4_sessions(quiz_id):
    """Test 4: Session Management"""
    print_header("TEST 4: SESSION MANAGEMENT")
    
    # Create Session
    session_data = {
        "host_id": "test_user_123",
        "mode": "self_paced"
    }
    
    response = test_endpoint("POST", f"/api/quiz/{quiz_id}/create-session", data=session_data, name="Create Quiz Session", expected_status=200)
    
    if not response or "session_code" not in response:
        return None
    
    session_code = response["session_code"]
    
    # Get Session Info
    test_endpoint("GET", f"/api/session/{session_code}", name="Get Session Info", expected_status=200)
    
    # Join Session
    participant_data = {
        "user_id": "participant_123",
        "username": "Test Participant"
    }
    test_endpoint("POST", f"/api/session/{session_code}/join", data=participant_data, name="Join Session", expected_status=200)
    
    # Get Participants
    test_endpoint("GET", f"/api/session/{session_code}/participants", name="Get Session Participants", expected_status=200)
    
    # Start Session
    test_endpoint("POST", f"/api/session/{session_code}/start?host_id=test_user_123", name="Start Session", expected_status=200)
    
    return session_code

def test_5_add_to_library(session_code):
    """Test 5: Add Quiz to Library"""
    print_header("TEST 5: ADD QUIZ TO LIBRARY")
    
    data = {
        "user_id": "new_user_456",
        "quiz_code": session_code
    }
    
    test_endpoint("POST", "/quizzes/add-to-library", data=data, name="Add Quiz to Library via Code", expected_status=200)

def test_6_users():
    """Test 6: User Management"""
    print_header("TEST 6: USER MANAGEMENT")
    
    # Create User
    user_data = {
        "username": "test_user_auto",
        "email": "test@auto.com",
        "full_name": "Automated Test User"
    }
    
    response = test_endpoint("POST", "/users", data=user_data, name="Create User", expected_status=200)
    
    if not response or "user_id" not in response:
        return None
    
    user_id = response["user_id"]
    
    # Get User
    test_endpoint("GET", f"/users/{user_id}", name="Get User Profile", expected_status=200)
    
    # Update User
    test_endpoint("PUT", f"/users/{user_id}", data={"bio": "Updated bio"}, name="Update User Profile", expected_status=200)
    
    # Get User's Quizzes
    test_endpoint("GET", f"/users/{user_id}/quizzes", name="Get User's Quizzes", expected_status=200)
    
    return user_id

def test_7_reviews(quiz_id):
    """Test 7: Reviews & Ratings"""
    print_header("TEST 7: REVIEWS & RATINGS")
    
    # Add Review
    review_data = {
        "user_id": "test_reviewer",
        "username": "Test Reviewer",
        "rating": 5,
        "comment": "Great quiz! (Automated test)"
    }
    test_endpoint("POST", f"/quizzes/{quiz_id}/reviews", data=review_data, name="Add Review", expected_status=200)
    
    # Get Reviews
    test_endpoint("GET", f"/quizzes/{quiz_id}/reviews", name="Get Quiz Reviews", expected_status=200)

def test_8_analytics(quiz_id):
    """Test 8: Analytics & Stats"""
    print_header("TEST 8: ANALYTICS & STATISTICS")
    
    # Get Quiz Stats
    test_endpoint("GET", f"/quizzes/{quiz_id}/stats", name="Get Quiz Statistics", expected_status=200)
    
    # Record Attempt
    attempt_data = {
        "user_id": "test_user",
        "score": 2,
        "total_questions": 2,
        "time_taken": 60,
        "answers": [{"question_id": "1", "answer": 0}, {"question_id": "2", "answer": 0}]
    }
    test_endpoint("POST", f"/quizzes/{quiz_id}/attempt", data=attempt_data, name="Record Quiz Attempt", expected_status=200)
    
    # Get Attempts
    test_endpoint("GET", f"/quizzes/{quiz_id}/attempts", name="Get Quiz Attempts", expected_status=200)
    
    # Dashboard Stats
    test_endpoint("GET", "/dashboard/stats", name="Get Dashboard Statistics", expected_status=200)

def test_9_results_leaderboard(quiz_id):
    """Test 9: Results & Leaderboard"""
    print_header("TEST 9: RESULTS & LEADERBOARD")
    
    # Submit Result
    result_data = {
        "quiz_id": quiz_id,
        "user_id": "test_user_1",
        "username": "Test User 1",
        "score": 2,
        "total_questions": 2,
        "percentage": 100,
        "time_taken": 45
    }
    test_endpoint("POST", "/results", data=result_data, name="Submit Quiz Result", expected_status=200)
    
    # Get Results
    test_endpoint("GET", f"/results/{quiz_id}", name="Get Quiz Results", expected_status=200)
    
    # Get Leaderboard
    test_endpoint("GET", f"/leaderboard/{quiz_id}", name="Get Leaderboard", expected_status=200)

def test_10_categories():
    """Test 10: Categories, Tags & Languages"""
    print_header("TEST 10: CATEGORIES, TAGS & LANGUAGES")
    
    test_endpoint("GET", "/categories", name="Get All Categories", expected_status=200)
    test_endpoint("GET", "/languages", name="Get All Languages", expected_status=200)
    
    # Create Tag
    tag_data = {"name": "auto-test-tag", "description": "Created by automated test"}
    test_endpoint("POST", "/tags", data=tag_data, name="Create Tag", expected_status=200)
    
    # Get Tags
    test_endpoint("GET", "/tags", name="Get All Tags", expected_status=200)


# ============================================
# ERROR TEST CASES
# ============================================

def test_errors():
    """Test Error Scenarios"""
    print_header("ERROR HANDLING TESTS")
    print(f"{Colors.YELLOW}Testing how API handles invalid requests...{Colors.RESET}\n")
    
    # Test 1: Get Non-existent Quiz
    test_endpoint(
        "GET", 
        "/quizzes/000000000000000000000000?user_id=test_user", 
        name="Get Non-existent Quiz (Should Return 404/500)",
        expected_status=500,
        is_error_test=True
    )
    
    # Test 2: Get Non-existent User
    test_endpoint(
        "GET", 
        "/users/000000000000000000000000", 
        name="Get Non-existent User (Should Return 500)",
        expected_status=500,
        is_error_test=True
    )
    
    # Test 3: Create Quiz with Missing Required Fields
    invalid_quiz = {
        "title": "",  # Empty title
        "description": "Test",
        "language": "English",
        "category": "Test",
        "creatorId": "test",
        "questions": []
    }
    test_endpoint(
        "POST", 
        "/quizzes", 
        data=invalid_quiz,
        name="Create Quiz with Empty Title (Should Return 400)",
        expected_status=400,
        is_error_test=True
    )
    
    # Test 4: Create Quiz with No Questions
    invalid_quiz2 = {
        "title": "Test",
        "description": "Test",
        "language": "English",
        "category": "Test",
        "creatorId": "test",
        "questions": []  # No questions
    }
    test_endpoint(
        "POST", 
        "/quizzes", 
        data=invalid_quiz2,
        name="Create Quiz with No Questions (Should Return 400)",
        expected_status=400,
        is_error_test=True
    )
    
    # Test 5: Update Non-existent Quiz
    test_endpoint(
        "PUT", 
        "/quizzes/000000000000000000000000",
        data={"title": "Updated"},
        name="Update Non-existent Quiz (Should Return 404/500)",
        expected_status=500,
        is_error_test=True
    )
    
    # Test 6: Delete Non-existent Quiz
    test_endpoint(
        "DELETE", 
        "/quizzes/999999999999999999999999",
        name="Delete Non-existent Quiz (Should Return 500)",
        expected_status=500,
        is_error_test=True
    )
    
    # Test 7: Get Non-existent Session
    test_endpoint(
        "GET", 
        "/api/session/INVALID123",
        name="Get Non-existent Session (Should Return 404)",
        expected_status=404,
        is_error_test=True
    )
    
    # Test 8: Join Session with Invalid Code
    test_endpoint(
        "POST", 
        "/api/session/BADCODE/join",
        data={"user_id": "test", "username": "Test"},
        name="Join Session with Invalid Code (Should Return 404)",
        expected_status=404,
        is_error_test=True
    )
    
    # Test 9: Add to Library with Invalid Code
    test_endpoint(
        "POST", 
        "/quizzes/add-to-library",
        data={"user_id": "test", "quiz_code": "INVALID999"},
        name="Add to Library with Invalid Code (Should Return 404)",
        expected_status=404,
        is_error_test=True
    )
    
    # Test 10: Access Quiz without Permission (Wrong User)
    # First create a quiz
    quiz_data = {
        "title": "Private Quiz",
        "description": "Test",
        "language": "English",
        "category": "Test",
        "creatorId": "owner_123",
        "questions": [{"id": "1", "questionText": "Q?", "type": "single", "options": ["A", "B"], "correctAnswerIndex": 0}]
    }
    response = test_endpoint("POST", "/quizzes", data=quiz_data, name="Create Private Quiz for Permission Test", expected_status=200)
    
    if response and "id" in response:
        quiz_id = response["id"]
        # Try to access with different user
        test_endpoint(
            "GET", 
            f"/quizzes/{quiz_id}?user_id=hacker_999",
            name="Access Quiz as Wrong User (Should Return 403)",
            expected_status=403,
            is_error_test=True
        )

def test_cleanup(quiz_id):
    """Cleanup Test Data"""
    print_header("CLEANUP")
    test_endpoint("DELETE", f"/quizzes/{quiz_id}", name="Delete Test Quiz", expected_status=200)


def print_summary():
    """Print test summary"""
    print_header("TEST SUMMARY")
    
    total = RESULTS["passed"] + RESULTS["failed"]
    pass_rate = (RESULTS["passed"] / total * 100) if total > 0 else 0
    
    print(f"\n{Colors.BOLD}{Colors.CYAN}╔═══════════════════════════════════════════════╗{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}║           FINAL TEST RESULTS                  ║{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}╚═══════════════════════════════════════════════╝{Colors.RESET}\n")
    
    print(f"{Colors.BOLD}Total Tests Executed: {total}{Colors.RESET}")
    print(f"{Colors.GREEN}{Colors.BOLD}✓ Tests Passed: {RESULTS['passed']}{Colors.RESET}")
    print(f"{Colors.YELLOW}{Colors.BOLD}  (Including {RESULTS['error_tests_passed']} error handling tests){Colors.RESET}")
    print(f"{Colors.RED}{Colors.BOLD}✗ Tests Failed: {RESULTS['failed']}{Colors.RESET}")
    
    # Progress bar
    bar_length = 40
    filled = int(bar_length * RESULTS['passed'] / total) if total > 0 else 0
    bar = '█' * filled + '░' * (bar_length - filled)
    
    bar_color = Colors.GREEN if pass_rate == 100 else Colors.YELLOW if pass_rate >= 75 else Colors.RED
    
    print(f"\n{bar_color}[{bar}] {pass_rate:.1f}%{Colors.RESET}\n")
    
    if RESULTS["failed"] > 0:
        print(f"{Colors.RED}{Colors.BOLD}Failed Tests:{Colors.RESET}")
        for test in RESULTS["tests"]:
            if test["status"] == "FAIL":
                print(f"{Colors.RED}  ✗ {test['name']}{Colors.RESET}")
    else:
        print(f"{Colors.GREEN}{Colors.BOLD}🎉 ALL TESTS PASSED! 🎉{Colors.RESET}\n")


def main():
    """Main test runner"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║                                                           ║")
    print("║   🚀 COMPREHENSIVE API TESTING - QUIZ APP 🚀             ║")
    print("║                                                           ║")
    print("║   Testing Success Cases + Error Handling                 ║")
    print("║                                                           ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    print(f"{Colors.RESET}\n")
    
    print(f"{Colors.CYAN}Target Server: {BASE_URL}{Colors.RESET}\n")
    
    start_time = time.time()
    
    # Success Tests
    if not test_1_health_check():
        print(f"\n{Colors.RED}{Colors.BOLD}❌ Server not running!{Colors.RESET}\n")
        return 1
    
    quiz_id = test_2_quiz_crud()
    if quiz_id:
        test_3_search_and_filter()
        session_code = test_4_sessions(quiz_id)
        if session_code:
            test_5_add_to_library(session_code)
        test_7_reviews(quiz_id)
        test_8_analytics(quiz_id)
        test_9_results_leaderboard(quiz_id)
    
    test_6_users()
    test_10_categories()
    
    # Error Tests
    test_errors()
    
    # Cleanup
    if quiz_id:
        test_cleanup(quiz_id)
    
    # Summary
    end_time = time.time()
    print_summary()
    print(f"{Colors.CYAN}⏱️  Total Time: {end_time - start_time:.2f} seconds{Colors.RESET}\n")
    
    return 0 if RESULTS["failed"] == 0 else 1

if __name__ == "__main__":
    exit(main())
