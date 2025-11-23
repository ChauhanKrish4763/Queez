"""
Test Script for Quiz Hosting API Endpoints
Run this to verify all endpoints are working correctly
"""

import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000"  # Change to your backend URL
TEST_QUIZ_ID = "test_quiz_123"
TEST_HOST_ID = "test_host_123"

def print_section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

def test_create_session():
    print_section("TEST 1: Create Session")
    
    url = f"{BASE_URL}/api/quiz/{TEST_QUIZ_ID}/create-session"
    data = {
        "quiz_id": TEST_QUIZ_ID,
        "host_id": TEST_HOST_ID,
        "mode": "live_multiplayer"
    }
    
    try:
        response = requests.post(url, json=data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code in [200, 201]:
            session_code = response.json().get('session_code')
            print(f"✅ SUCCESS - Session created with code: {session_code}")
            return session_code
        else:
            print(f"❌ FAILED - Status {response.status_code}")
            return None
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return None

def test_get_session_info(session_code):
    print_section("TEST 2: Get Session Info")
    
    url = f"{BASE_URL}/api/session/{session_code}"
    
    try:
        response = requests.get(url)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code == 200:
            print("✅ SUCCESS - Session info retrieved")
            return True
        else:
            print(f"❌ FAILED - Status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_get_participants(session_code):
    print_section("TEST 3: Get Participants")
    
    url = f"{BASE_URL}/api/session/{session_code}/participants"
    
    try:
        response = requests.get(url)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code == 200:
            count = response.json().get('participant_count', 0)
            print(f"✅ SUCCESS - {count} participants found")
            return True
        else:
            print(f"❌ FAILED - Status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_join_session(session_code):
    print_section("TEST 4: Join Session")
    
    url = f"{BASE_URL}/api/session/{session_code}/join"
    data = {
        "user_id": "test_user_1",
        "username": "Test User 1"
    }
    
    try:
        response = requests.post(url, json=data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code in [200, 201]:
            print("✅ SUCCESS - User joined session")
            return True
        else:
            print(f"❌ FAILED - Status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_start_session(session_code):
    print_section("TEST 5: Start Session")
    
    url = f"{BASE_URL}/api/session/{session_code}/start"
    data = {"host_id": TEST_HOST_ID}
    
    try:
        response = requests.post(url, json=data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code in [200, 201]:
            print("✅ SUCCESS - Session started")
            return True
        else:
            print(f"❌ FAILED - Status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_end_session(session_code):
    print_section("TEST 6: End Session")
    
    url = f"{BASE_URL}/api/session/{session_code}/end"
    data = {"host_id": TEST_HOST_ID}
    
    try:
        response = requests.post(url, json=data)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        
        if response.status_code in [200, 201]:
            print("✅ SUCCESS - Session ended")
            return True
        else:
            print(f"❌ FAILED - Status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def main():
    print("\n" + "="*60)
    print("  QUIZ HOSTING API - TEST SUITE")
    print("="*60)
    print(f"\nBase URL: {BASE_URL}")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Test sequence
    session_code = test_create_session()
    
    if session_code:
        test_get_session_info(session_code)
        test_get_participants(session_code)
        test_join_session(session_code)
        test_get_participants(session_code)  # Check count increased
        test_start_session(session_code)
        test_end_session(session_code)
    else:
        print("\n❌ CRITICAL: Could not create session. Check backend is running.")
    
    print("\n" + "="*60)
    print("  TEST SUITE COMPLETE")
    print("="*60 + "\n")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Tests interrupted by user")
    except Exception as e:
        print(f"\n\n❌ CRITICAL ERROR: {e}")
