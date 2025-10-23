import secrets
import string

def generate_session_code(length: int = 6) -> str:
    """Generate a unique alphanumeric session code"""
    characters = string.ascii_uppercase + string.digits
    return ''.join(secrets.choice(characters) for _ in range(length))
