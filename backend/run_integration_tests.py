#!/usr/bin/env python
"""
Integration Test Runner for Live Quiz Critical Bugs

This script runs both integration tests sequentially to avoid
event loop conflicts with Motor (MongoDB async driver) on Windows.
"""
import subprocess
import sys

def run_test(test_name):
    """Run a single test and return the result"""
    print(f"\n{'='*80}")
    print(f"Running: {test_name}")
    print('='*80)
    
    cmd = [
        sys.executable, "-m", "pytest",
        f"tests/test_integration_bug_fixes.py::{test_name}",
        "-v", "-s"
    ]
    
    result = subprocess.run(cmd, cwd=".")
    return result.returncode

def main():
    """Run all integration tests"""
    print("\n" + "="*80)
    print("INTEGRATION TEST SUITE: Live Quiz Critical Bugs")
    print("="*80)
    
    tests = [
        "test_complete_quiz_flow_with_all_fixes",
        "test_drag_drop_question_flow"
    ]
    
    results = {}
    
    for test in tests:
        returncode = run_test(test)
        results[test] = "✅ PASSED" if returncode == 0 else "❌ FAILED"
    
    # Print summary
    print("\n" + "="*80)
    print("TEST SUMMARY")
    print("="*80)
    
    for test, status in results.items():
        print(f"{status} - {test}")
    
    # Check if all passed
    all_passed = all("PASSED" in status for status in results.values())
    
    if all_passed:
        print("\n✅ ALL INTEGRATION TESTS PASSED!")
        return 0
    else:
        print("\n❌ SOME TESTS FAILED")
        return 1

if __name__ == "__main__":
    sys.exit(main())
