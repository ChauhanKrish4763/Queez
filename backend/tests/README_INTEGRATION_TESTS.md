# Integration Tests - Live Quiz Critical Bugs

## Overview

This directory contains comprehensive integration tests for all 6 critical bug fixes in the live multiplayer quiz feature.

## Test Files

- **`test_integration_bug_fixes.py`** - Main integration test suite
- **`INTEGRATION_TEST_RESULTS.md`** - Detailed test results and coverage
- **`run_integration_tests.py`** - Test runner script (in parent directory)

## Running Tests

### Option 1: Use the Test Runner (Recommended)

```bash
cd backend
python run_integration_tests.py
```

This script runs both tests sequentially and provides a summary.

### Option 2: Run Tests Individually

Due to Motor (MongoDB async driver) event loop limitations on Windows, you can run tests individually:

```bash
cd backend

# Test 7.1: Complete quiz flow with all fixes
python -m pytest tests/test_integration_bug_fixes.py::test_complete_quiz_flow_with_all_fixes -v -s

# Test 7.2: Drag-and-drop question flow
python -m pytest tests/test_integration_bug_fixes.py::test_drag_drop_question_flow -v -s
```

## Test Coverage

### Test 7.1: Complete Quiz Flow with All Fixes

**Validates:**
- ✅ Bug 1: Host Final Results Page
- ✅ Bug 3: Self-Paced Progression
- ✅ Bug 4: Points Calculation with Time Bonuses
- ✅ Bug 5: Answer Feedback Timing
- ✅ Bug 6: Mid-Quiz Leaderboard Filtering

**Scenario:**
- Host + 3 participants (Alice, Bob, Charlie)
- Multiple questions with different answer speeds
- Verifies self-paced progression
- Verifies time-based scoring (1000 base + up to 500 bonus)
- Verifies leaderboard shows all participants
- Verifies final rankings for podium

### Test 7.2: Drag-and-Drop Question Flow

**Validates:**
- ✅ Bug 2: Drag-and-Drop Functionality
- ✅ Bug 2: Correct/Incorrect Evaluation
- ✅ Bug 4: Points Calculation for Drag-Drop
- ✅ Bug 3: Self-Paced Progression

**Scenario:**
- 2 participants (Alice, Bob)
- Drag-and-drop question (arrange numbers)
- Alice submits correct answer
- Bob submits incorrect answer
- Verifies evaluation and scoring

## Requirements Validated

| Requirement | Description | Test |
|-------------|-------------|------|
| 1.1, 1.2, 1.3 | Host Final Results Page | 7.1 |
| 2.1, 2.2, 2.3, 2.4, 2.5 | Drag-and-Drop Functionality | 7.2 |
| 3.1, 3.2, 3.3, 3.4 | Self-Paced Progression | 7.1, 7.2 |
| 4.1, 4.2, 4.3, 4.4, 4.5 | Points Calculation | 7.1, 7.2 |
| 5.1, 5.2, 5.3, 5.4 | Answer Feedback Timing | 7.1 |
| 6.1, 6.2, 6.3, 6.4, 6.5 | Mid-Quiz Leaderboard | 7.1 |

## Test Results

✅ **All tests passed successfully!**

See `INTEGRATION_TEST_RESULTS.md` for detailed results.

## Prerequisites

- MongoDB running on localhost:27017
- Redis running on localhost:6379
- Python dependencies installed (`pip install -r requirements.txt`)

## Test Data

Tests create temporary data in MongoDB and Redis:
- Test quizzes with multiple questions
- Test sessions with participants
- All data is cleaned up after test execution

## Known Issues

When running both tests together with `pytest tests/test_integration_bug_fixes.py`, you may encounter an event loop error due to Motor's async driver on Windows. This is a known limitation and does not affect test validity. Use the test runner script or run tests individually.

## Troubleshooting

### Event Loop Closed Error

If you see `RuntimeError: Event loop is closed`, run tests individually or use the test runner script.

### MongoDB Connection Error

Ensure MongoDB is running:
```bash
# Check if MongoDB is running
mongosh --eval "db.version()"
```

### Redis Connection Error

Ensure Redis is running:
```bash
# Check if Redis is running
redis-cli ping
```

## Contributing

When adding new integration tests:
1. Follow the existing test structure
2. Use descriptive test names
3. Include comprehensive assertions
4. Clean up test data in fixtures
5. Document test coverage in comments
6. Update this README with new tests

## Contact

For questions or issues with integration tests, refer to the spec document at:
`.kiro/specs/live-quiz-critical-bugs/`
