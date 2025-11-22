"""
LEGACY ENTRY POINT - REDIRECTS TO NEW MODULAR STRUCTURE

This file is kept for backwards compatibility.
The application has been refactored into a modular structure.

New structure location: app/main.py

To run the application:
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

Or using this legacy file:
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

# Import the refactored application
from app.main import app

# Re-export for backwards compatibility
__all__ = ['app']


# Local development:
# uvicorn main:app --host 0.0.0.0 --port 8000 --reload