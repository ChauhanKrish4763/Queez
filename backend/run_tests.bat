@echo off
echo.
echo ========================================
echo   AUTOMATED API TESTING - QUIZ APP
echo ========================================
echo.

REM Check if server is running
echo [1/3] Checking if server is running...
curl -s http://localhost:8000/ >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Server is not running!
    echo.
    echo Please start the server first:
    echo   cd backend
    echo   python -m uvicorn main:app --reload
    echo.
    pause
    exit /b 1
)   
echo [OK] Server is running!
echo.

REM Check if requests is installed
echo [2/3] Checking Python dependencies...
python -c "import requests" 2>nul
if errorlevel 1 (
    echo [INSTALLING] Installing 'requests' library...
    pip install requests
    echo.
)
echo [OK] Dependencies ready!
echo.

REM Run the tests
echo [3/3] Running automated tests...
echo.
python test_api_automated.py

echo.
echo ========================================
echo   TESTING COMPLETE
echo ========================================
echo.
pause
