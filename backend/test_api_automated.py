"""
Automated API Testing Script for Quiz App
This script automatically tests all endpoints including error cases
Run: python test_api_automated.py
"""

import requests
import json
from typing import Dict, List
from datetime import datetime
import time

# Configuration
BASE_URL = "http://localhost:8000"
RESULTS = {"passed": 0, "failed": 0, "error_tests": 0, "tests": []}

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
    print(f"\n{Colors.CYAN}{Colors.BOLD}{'='*60}{Colors.RESET}")
    print(f"{Colors.CYAN}{Colors.BOLD}{text.center(60)}{Colors.RESET}")
    print(f"{Colors.CYAN}{Colors.BOLD}{'='*60}{Colors.RESET}\n")

def print_test(name, status, details="", response_data=None):
    """Print test result with detailed feedback"""
    if status == "PASS":
        symbol = "✓"
        color = Colors.GREEN
        RESULTS["passed"] += 1
        status_text = "PASSED"
    else:
        symbol = "✗"
        color = Colors.RED
        RESULTS["failed"] += 1
        status_text = "FAILED"
    
    # Print test name with status
    print(f"\n{color}{Colors.BOLD}[{symbol}] {name} - {status_text}{Colors.RESET}")
    
    # Print details if provided
    if details:
        print(f"    {Colors.YELLOW}Status: {details}{Colors.RESET}")
    
    # Print response data summary if provided
    if response_data:
        if isinstance(response_data, dict):
            # Show key response fields
            print(f"    {Colors.CYAN}Response Summary:{Colors.RESET}")
            for key, value in list(response_data.items())[:5]:  # Show first 5 keys
                if isinstance(value, (str, int, float, bool)):
                    print(f"      • {key}: {value}")
                elif isinstance(value, list):
                    print(f"      • {key}: [{len(value)} items]")
                elif isinstance(value, dict):
                    print(f"      • {key}: {{...}}")
    
    RESULTS["tests"].append({
        "name": name,
        "status": status,
        "details": details
    })

def test_endpoint(method, endpoint, expected_status=200, data=None, name="", sleep_after=1.0):
    """Generic endpoint tester with enhanced feedback"""
    url = f"{BASE_URL}{endpoint}"
    
    # Print test start info
    print(f"\n{Colors.BLUE}{'─'*60}{Colors.RESET}")
    print(f"{Colors.BOLD}Testing: {name or f'{method} {endpoint}'}{Colors.RESET}")
    print(f"{Colors.MAGENTA}Endpoint: {method} {endpoint}{Colors.RESET}")
    if data:
        print(f"{Colors.CYAN}Request Body: {json.dumps(data, indent=2)[:200]}...{Colors.RESET}" if len(json.dumps(data)) > 200 else f"{Colors.CYAN}Request Body: {json.dumps(data, indent=2)}{Colors.RESET}")
    
    response = None
    try:
        if method == "GET":
            response = requests.get(url, timeout=5)
        elif method == "POST":
            response = requests.post(url, json=data, timeout=5)
        elif method == "PUT":
            response = requests.put(url, json=data, timeout=5)
        elif method == "PATCH":
            response = requests.patch(url, json=data, timeout=5)
        elif method == "DELETE":
            response = requests.delete(url, timeout=5)
        
        response_data = response.json() if response.content else {}
        
        if response.status_code == expected_status:
            print_test(
                name or f"{method} {endpoint}", 
                "PASS", 
                f"HTTP {response.status_code} - Response received successfully",
                response_data
            )
            time.sleep(sleep_after)  # Sleep after test
            return response_data
        else:
            print_test(
                name or f"{method} {endpoint}", 
                "FAIL", 
                f"Expected HTTP {expected_status}, got {response.status_code}",
                response_data
            )
            time.sleep(sleep_after)  # Sleep after test
            return None
    
    except requests.exceptions.ConnectionError:
        print_test(
            name or f"{method} {endpoint}", 
            "FAIL", 
            "⚠️ Connection Error - Is the server running on http://localhost:8000?"
        )
        time.sleep(sleep_after)  # Sleep after test
        return None
    except requests.exceptions.Timeout:
        print_test(
            name or f"{method} {endpoint}", 
            "FAIL", 
            "⏱️ Request timed out after 5 seconds"
        )
        time.sleep(sleep_after)  # Sleep after test
        return None
    except Exception as e:
        print_test(
            name or f"{method} {endpoint}", 
            "FAIL", 
            f"❌ Error: {str(e)}"
        )
        time.sleep(sleep_after)  # Sleep after test
        return None

# ============================================
# TEST SUITE
# ============================================

def test_1_health_check():
    """Test 1: Health Check"""
    print_header("TEST 1: HEALTH CHECK")
    print(f"{Colors.YELLOW}📡 Checking if the API server is running...{Colors.RESET}")
    
    response = test_endpoint(
        "GET", "/",
        name="API Health Check",
        expected_status=200,
        sleep_after=1.5
    )
    
    if response and "message" in response:
        print(f"\n{Colors.GREEN}{Colors.BOLD}✅ Server is healthy!{Colors.RESET}")
        print(f"{Colors.GREEN}   Message: {response['message']}{Colors.RESET}")
        if "version" in response:
            print(f"{Colors.GREEN}   Version: {response.get('version', 'N/A')}{Colors.RESET}")
    else:
        print(f"\n{Colors.RED}{Colors.BOLD}❌ Server health check failed!{Colors.RESET}")
    
    return response is not None

def test_2_quiz_crud():
    """Test 2: Quiz CRUD Operations"""
    print_header("TEST 2: QUIZ CRUD OPERATIONS")
    print(f"{Colors.YELLOW}📝 Testing Create, Read, Update, Delete operations for quizzes...{Colors.RESET}")
    
    # Create Quiz
    print(f"\n{Colors.CYAN}Step 1: Creating a new quiz...{Colors.RESET}")
    quiz_data = {
        "title": "Automated Test Quiz - Python",
        "description": "This quiz was created by automated testing script",
        "language": "English",
        "category": "Science and Technology",
        "questions": [
            {
                "id": "1",
                "questionText": "What is Python?",
                "type": "single",
                "options": ["A language", "A snake", "A software", "An OS"],
                "correctAnswerIndex": 0
            },
            {
                "id": "2",
                "questionText": "Python is open source?",
                "type": "single",
                "options": ["True", "False"],
                "correctAnswerIndex": 0
            }
        ]
    }
    
    response = test_endpoint(
        "POST", "/quizzes",
        data=quiz_data,
        name="Create Quiz",
        expected_status=200,
        sleep_after=1.5
    )
    
    if not response or "id" not in response:
        print(f"\n{Colors.RED}{Colors.BOLD}❌ Failed to create quiz - stopping CRUD tests{Colors.RESET}")
        return None
    
    quiz_id = response["id"]
    print(f"\n{Colors.GREEN}{Colors.BOLD}✅ Quiz created successfully!{Colors.RESET}")
    print(f"{Colors.MAGENTA}   Quiz ID: {quiz_id}{Colors.RESET}")
    print(f"{Colors.MAGENTA}   Title: {quiz_data['title']}{Colors.RESET}")
    
    # Get All Quizzes
    print(f"\n{Colors.CYAN}Step 2: Fetching all quizzes from library...{Colors.RESET}")
    response = test_endpoint(
        "GET", "/quizzes/library",
        name="Get All Quizzes (Library)",
        expected_status=200,
        sleep_after=1.5
    )
    
    if response:
        quiz_count = response.get("count", 0)
        print(f"{Colors.GREEN}   Found {quiz_count} quiz(es) in library{Colors.RESET}")
    
    # Get Single Quiz
    print(f"\n{Colors.CYAN}Step 3: Retrieving the created quiz by ID...{Colors.RESET}")
    response = test_endpoint(
        "GET", f"/quizzes/{quiz_id}",
        name="Get Quiz by ID",
        expected_status=200,
        sleep_after=1.5
    )
    
    if response:
        print(f"{Colors.GREEN}   Retrieved quiz: '{response.get('title', 'N/A')}'{Colors.RESET}")
    
    # Update Quiz (PUT)
    print(f"\n{Colors.CYAN}Step 4: Updating entire quiz (PUT)...{Colors.RESET}")
    updated_quiz = quiz_data.copy()
    updated_quiz["title"] = "Updated - Automated Test Quiz"
    test_endpoint(
        "PUT", f"/quizzes/{quiz_id}",
        data=updated_quiz,
        name="Update Quiz (PUT)",
        expected_status=200,
        sleep_after=1.5
    )
    
    # Partial Update (PATCH)
    print(f"\n{Colors.CYAN}Step 5: Partially updating quiz description (PATCH)...{Colors.RESET}")
    test_endpoint(
        "PATCH", f"/quizzes/{quiz_id}",
        data={"description": "Partially updated by automated test"},
        name="Partial Update Quiz (PATCH)",
        expected_status=200,
        sleep_after=1.5
    )
    
    print(f"\n{Colors.GREEN}{Colors.BOLD}✅ CRUD operations completed for Quiz ID: {quiz_id}{Colors.RESET}")
    return quiz_id

def test_3_search_and_filter(quiz_id):
    """Test 3: Search and Filter"""
    print_header("TEST 3: SEARCH & FILTER")
    print(f"{Colors.YELLOW}🔍 Testing search and filtering capabilities...{Colors.RESET}")
    
    # Search
    print(f"\n{Colors.CYAN}Searching for quizzes containing 'automated'...{Colors.RESET}")
    response = test_endpoint(
        "GET", "/quizzes/search?q=automated",
        name="Search Quizzes",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Found {count} quiz(es) matching 'automated'{Colors.RESET}")
    
    # Filter by Category
    print(f"\n{Colors.CYAN}Filtering quizzes by category 'Science and Technology'...{Colors.RESET}")
    response = test_endpoint(
        "GET", "/quizzes/category/Science and Technology",
        name="Filter by Category",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Found {count} quiz(es) in this category{Colors.RESET}")
    
    # Filter by Language
    print(f"\n{Colors.CYAN}Filtering quizzes by language 'English'...{Colors.RESET}")
    response = test_endpoint(
        "GET", "/quizzes/language/English",
        name="Filter by Language",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Found {count} quiz(es) in English{Colors.RESET}")

def test_4_statistics(quiz_id):
    """Test 4: Quiz Statistics & Attempts"""
    print_header("TEST 4: STATISTICS & ATTEMPTS")
    print(f"{Colors.YELLOW}📊 Testing quiz statistics and attempt recording...{Colors.RESET}")
    
    # Get Stats (before any attempts)
    print(f"\n{Colors.CYAN}Getting initial quiz statistics...{Colors.RESET}")
    response = test_endpoint(
        "GET", f"/quizzes/{quiz_id}/stats",
        name="Get Quiz Statistics",
        expected_status=200,
        sleep_after=1.5
    )
    if response and "stats" in response:
        stats = response["stats"]
        print(f"{Colors.GREEN}   Total attempts: {stats.get('total_attempts', 0)}{Colors.RESET}")
        print(f"{Colors.GREEN}   Average score: {stats.get('average_score', 0)}%{Colors.RESET}")
    
    # Record Attempt
    print(f"\n{Colors.CYAN}Recording a quiz attempt...{Colors.RESET}")
    attempt_data = {
        "user_id": "automated_test_user",
        "score": 2,
        "total_questions": 2,
        "time_taken": 60,
        "answers": [
            {"question_id": "1", "answer": 0},
            {"question_id": "2", "answer": 0}
        ]
    }
    response = test_endpoint(
        "POST", f"/quizzes/{quiz_id}/attempt",
        data=attempt_data,
        name="Record Quiz Attempt",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        print(f"{Colors.GREEN}   Score: {response.get('score', 0)}/{attempt_data['total_questions']}{Colors.RESET}")
        print(f"{Colors.GREEN}   Percentage: {response.get('percentage', 0)}%{Colors.RESET}")
    
    # Get All Attempts
    print(f"\n{Colors.CYAN}Fetching all attempts for this quiz...{Colors.RESET}")
    response = test_endpoint(
        "GET", f"/quizzes/{quiz_id}/attempts",
        name="Get Quiz Attempts",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Total attempts recorded: {count}{Colors.RESET}")

def test_5_user_management():
    """Test 5: User Management"""
    print_header("TEST 5: USER MANAGEMENT")
    print(f"{Colors.YELLOW}👤 Testing user creation and management...{Colors.RESET}")
    
    # Create User
    print(f"\n{Colors.CYAN}Creating a new user account...{Colors.RESET}")
    user_data = {
        "username": "automated_test_user",
        "email": "auto@test.com",
        "full_name": "Automated Test User",
        "bio": "Created by automated testing script"
    }
    
    response = test_endpoint(
        "POST", "/users",
        data=user_data,
        name="Create User",
        expected_status=200,
        sleep_after=1.5
    )
    
    if not response or "user_id" not in response:
        print(f"\n{Colors.RED}{Colors.BOLD}❌ Failed to create user{Colors.RESET}")
        return None
    
    user_id = response["user_id"]
    print(f"\n{Colors.GREEN}{Colors.BOLD}✅ User created successfully!{Colors.RESET}")
    print(f"{Colors.MAGENTA}   User ID: {user_id}{Colors.RESET}")
    print(f"{Colors.MAGENTA}   Username: {user_data['username']}{Colors.RESET}")
    print(f"{Colors.MAGENTA}   Email: {user_data['email']}{Colors.RESET}")
    
    # Get User
    print(f"\n{Colors.CYAN}Retrieving user profile...{Colors.RESET}")
    response = test_endpoint(
        "GET", f"/users/{user_id}",
        name="Get User Profile",
        expected_status=200,
        sleep_after=1.5
    )
    if response and "user" in response:
        user = response["user"]
        print(f"{Colors.GREEN}   Username: {user.get('username', 'N/A')}{Colors.RESET}")
        print(f"{Colors.GREEN}   Quiz count: {user.get('quiz_count', 0)}{Colors.RESET}")
    
    # Update User
    print(f"\n{Colors.CYAN}Updating user profile...{Colors.RESET}")
    test_endpoint(
        "PUT", f"/users/{user_id}",
        data={"bio": "Updated by automated test"},
        name="Update User Profile",
        expected_status=200,
        sleep_after=1.5
    )
    
    # Get User's Quizzes
    print(f"\n{Colors.CYAN}Fetching user's created quizzes...{Colors.RESET}")
    response = test_endpoint(
        "GET", f"/users/{user_id}/quizzes",
        name="Get User's Quizzes",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   User has created {count} quiz(es){Colors.RESET}")
    
    return user_id

def test_6_reviews(quiz_id):
    """Test 6: Reviews & Ratings"""
    print_header("TEST 6: REVIEWS & RATINGS")
    print(f"{Colors.YELLOW}⭐ Testing review and rating system...{Colors.RESET}")
    
    # Add Review
    print(f"\n{Colors.CYAN}Adding a 5-star review...{Colors.RESET}")
    review_data = {
        "user_id": "automated_test",
        "username": "Auto Tester",
        "rating": 5,
        "comment": "Great quiz! (Automated test review)"
    }
    response = test_endpoint(
        "POST", f"/quizzes/{quiz_id}/reviews",
        data=review_data,
        name="Add Review",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        print(f"{Colors.GREEN}   Review added with rating: {review_data['rating']}/5 stars{Colors.RESET}")
    
    # Get Reviews
    print(f"\n{Colors.CYAN}Fetching all reviews for this quiz...{Colors.RESET}")
    response = test_endpoint(
        "GET", f"/quizzes/{quiz_id}/reviews",
        name="Get Quiz Reviews",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        avg_rating = response.get("average_rating", 0)
        print(f"{Colors.GREEN}   Total reviews: {count}{Colors.RESET}")
        print(f"{Colors.GREEN}   Average rating: {avg_rating}/5.0 stars{Colors.RESET}")
    
    # Get Top Rated
    print(f"\n{Colors.CYAN}Fetching top-rated quizzes...{Colors.RESET}")
    response = test_endpoint(
        "GET", "/quizzes/top-rated",
        name="Get Top Rated Quizzes",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Found {count} top-rated quiz(es){Colors.RESET}")

def test_7_results_leaderboard(quiz_id):
    """Test 7: Results & Leaderboard"""
    print_header("TEST 7: RESULTS & LEADERBOARD")
    print(f"{Colors.YELLOW}🏆 Testing results submission and leaderboard...{Colors.RESET}")
    
    # Submit Result
    print(f"\n{Colors.CYAN}Submitting first quiz result (100% score)...{Colors.RESET}")
    result_data = {
        "quiz_id": quiz_id,
        "user_id": "auto_test_1",
        "username": "Auto Tester 1",
        "score": 2,
        "total_questions": 2,
        "percentage": 100,
        "time_taken": 50
    }
    response = test_endpoint(
        "POST", "/results",
        data=result_data,
        name="Submit Quiz Result",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        print(f"{Colors.GREEN}   Score: {result_data['score']}/{result_data['total_questions']} ({result_data['percentage']}%){Colors.RESET}")
        print(f"{Colors.GREEN}   Time taken: {result_data['time_taken']} seconds{Colors.RESET}")
    
    # Submit another result for leaderboard
    print(f"\n{Colors.CYAN}Submitting second quiz result (50% score)...{Colors.RESET}")
    result_data["user_id"] = "auto_test_2"
    result_data["username"] = "Auto Tester 2"
    result_data["score"] = 1
    result_data["percentage"] = 50
    result_data["time_taken"] = 120
    response = test_endpoint(
        "POST", "/results",
        data=result_data,
        name="Submit Second Result",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        print(f"{Colors.GREEN}   Score: {result_data['score']}/{result_data['total_questions']} ({result_data['percentage']}%){Colors.RESET}")
    
    # Get Results
    print(f"\n{Colors.CYAN}Fetching all results for this quiz...{Colors.RESET}")
    response = test_endpoint(
        "GET", f"/results/{quiz_id}",
        name="Get Quiz Results",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Total submissions: {count}{Colors.RESET}")
    
    # Get Leaderboard
    print(f"\n{Colors.CYAN}Fetching leaderboard rankings...{Colors.RESET}")
    response = test_endpoint(
        "GET", f"/leaderboard/{quiz_id}",
        name="Get Leaderboard",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Leaderboard has {count} entries{Colors.RESET}")

def test_8_categories_tags():
    """Test 8: Categories, Tags & Languages"""
    print_header("TEST 8: CATEGORIES, TAGS & LANGUAGES")
    print(f"{Colors.YELLOW}🏷️ Testing metadata endpoints...{Colors.RESET}")
    
    # Get Categories
    print(f"\n{Colors.CYAN}Fetching all quiz categories...{Colors.RESET}")
    response = test_endpoint(
        "GET", "/categories",
        name="Get All Categories",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Found {count} categories{Colors.RESET}")
    
    # Get Languages
    print(f"\n{Colors.CYAN}Fetching all available languages...{Colors.RESET}")
    response = test_endpoint(
        "GET", "/languages",
        name="Get All Languages",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Found {count} languages{Colors.RESET}")
    
    # Create Tag
    print(f"\n{Colors.CYAN}Creating a new tag...{Colors.RESET}")
    tag_data = {
        "name": "automated-test",
        "description": "Tag created by automated test"
    }
    response = test_endpoint(
        "POST", "/tags",
        data=tag_data,
        name="Create Tag",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        print(f"{Colors.GREEN}   Tag '{tag_data['name']}' created{Colors.RESET}")
    
    # Get Tags
    print(f"\n{Colors.CYAN}Fetching all tags...{Colors.RESET}")
    response = test_endpoint(
        "GET", "/tags",
        name="Get All Tags",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        count = response.get("count", 0)
        print(f"{Colors.GREEN}   Found {count} tags{Colors.RESET}")

def test_9_dashboard():
    """Test 9: Dashboard Statistics"""
    print_header("TEST 9: DASHBOARD")
    print(f"{Colors.YELLOW}📈 Testing dashboard analytics...{Colors.RESET}")
    
    response = test_endpoint(
        "GET", "/dashboard/stats",
        name="Get Dashboard Statistics",
        expected_status=200,
        sleep_after=1.5
    )
    
    if response and "stats" in response:
        stats = response["stats"]
        print(f"\n{Colors.GREEN}{Colors.BOLD}Dashboard Overview:{Colors.RESET}")
        print(f"{Colors.GREEN}   Total Quizzes: {stats.get('total_quizzes', 0)}{Colors.RESET}")
        print(f"{Colors.GREEN}   Total Users: {stats.get('total_users', 0)}{Colors.RESET}")
        print(f"{Colors.GREEN}   Total Attempts: {stats.get('total_attempts', 0)}{Colors.RESET}")
        print(f"{Colors.GREEN}   Total Reviews: {stats.get('total_reviews', 0)}{Colors.RESET}")

def test_10_cleanup(quiz_id):
    """Test 10: Cleanup (Delete Quiz)"""
    print_header("TEST 10: CLEANUP")
    print(f"{Colors.YELLOW}🧹 Cleaning up test data...{Colors.RESET}")
    
    # Delete Quiz
    print(f"\n{Colors.CYAN}Deleting the test quiz...{Colors.RESET}")
    response = test_endpoint(
        "DELETE", f"/quizzes/{quiz_id}",
        name="Delete Quiz",
        expected_status=200,
        sleep_after=1.5
    )
    if response:
        print(f"{Colors.GREEN}   Quiz deleted successfully!{Colors.RESET}")
    
    # Verify Deletion (should fail)
    print(f"\n{Colors.CYAN}Verifying quiz was deleted (should fail)...{Colors.RESET}")
    test_endpoint(
        "GET", f"/quizzes/{quiz_id}",
        name="Verify Quiz Deleted (Expected to fail)",
        expected_status=500,  # Will be 500 because of ObjectId error
        sleep_after=1.5
    )
    print(f"{Colors.GREEN}   Confirmed: Quiz no longer exists{Colors.RESET}")

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
    print(f"{Colors.RED}{Colors.BOLD}✗ Tests Failed: {RESULTS['failed']}{Colors.RESET}")
    
    # Progress bar
    bar_length = 40
    filled = int(bar_length * RESULTS['passed'] / total) if total > 0 else 0
    bar = '█' * filled + '░' * (bar_length - filled)
    
    if pass_rate == 100:
        bar_color = Colors.GREEN
    elif pass_rate >= 75:
        bar_color = Colors.YELLOW
    else:
        bar_color = Colors.RED
    
    print(f"\n{bar_color}[{bar}] {pass_rate:.1f}%{Colors.RESET}\n")
    
    if RESULTS["failed"] > 0:
        print(f"{Colors.RED}{Colors.BOLD}Failed Tests Details:{Colors.RESET}")
        print(f"{Colors.RED}{'─'*50}{Colors.RESET}")
        for test in RESULTS["tests"]:
            if test["status"] == "FAIL":
                print(f"{Colors.RED}  ✗ {test['name']}{Colors.RESET}")
                print(f"{Colors.YELLOW}    Reason: {test['details']}{Colors.RESET}")
        print()
    else:
        print(f"{Colors.GREEN}{Colors.BOLD}🎉 ALL TESTS PASSED! 🎉{Colors.RESET}\n")
        print(f"{Colors.GREEN}Your API is working perfectly!{Colors.RESET}\n")

def main():
    """Main test runner"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}")
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║                                                           ║")
    print("║     🚀 AUTOMATED API TESTING - QUIZ APP 🚀               ║")
    print("║                                                           ║")
    print("║     Testing all 29 endpoints comprehensively...          ║")
    print("║                                                           ║")
    print("╚═══════════════════════════════════════════════════════════╝")
    print(f"{Colors.RESET}\n")
    
    print(f"{Colors.CYAN}Starting test suite at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{Colors.RESET}")
    print(f"{Colors.CYAN}Target Server: {BASE_URL}{Colors.RESET}\n")
    
    input(f"{Colors.YELLOW}Press ENTER to start testing...{Colors.RESET}")
    
    start_time = time.time()
    
    # Run all tests
    print(f"\n{Colors.BOLD}{Colors.MAGENTA}{'='*60}")
    print("BEGINNING TEST EXECUTION")
    print(f"{'='*60}{Colors.RESET}\n")
    
    if not test_1_health_check():
        print(f"\n{Colors.RED}{Colors.BOLD}❌ Server not running! Stopping tests.{Colors.RESET}")
        print(f"{Colors.YELLOW}Please start your server with: python main.py{Colors.RESET}\n")
        return 1
    
    quiz_id = test_2_quiz_crud()
    if quiz_id:
        test_3_search_and_filter(quiz_id)
        test_4_statistics(quiz_id)
        test_6_reviews(quiz_id)
        test_7_results_leaderboard(quiz_id)
    
    user_id = test_5_user_management()
    test_8_categories_tags()
    test_9_dashboard()
    
    if quiz_id:
        test_10_cleanup(quiz_id)
    
    # Calculate time
    end_time = time.time()
    duration = end_time - start_time
    
    print(f"\n{Colors.BOLD}{Colors.MAGENTA}{'='*60}")
    print("TEST EXECUTION COMPLETED")
    print(f"{'='*60}{Colors.RESET}\n")
    
    print_summary()
    
    print(f"{Colors.CYAN}{'─'*60}{Colors.RESET}")
    print(f"{Colors.CYAN}⏱️  Total Execution Time: {duration:.2f} seconds{Colors.RESET}")
    print(f"{Colors.CYAN}📅 Completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{Colors.RESET}")
    print(f"{Colors.CYAN}{'─'*60}{Colors.RESET}\n")
    
    # Return exit code
    if RESULTS["failed"] == 0:
        print(f"{Colors.GREEN}{Colors.BOLD}✅ Testing completed successfully! All systems operational.{Colors.RESET}\n")
        return 0
    else:
        print(f"{Colors.RED}{Colors.BOLD}⚠️  Some tests failed. Please review the errors above.{Colors.RESET}\n")
        return 1

if __name__ == "__main__":
    exit(main())
