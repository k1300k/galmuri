"""Authentication utilities for API key based auth"""
import hashlib
import secrets
from fastapi import Header, HTTPException, status
from app.config import settings


def generate_api_key(user_id: str) -> str:
    """
    Generate an API key for a user
    
    For MVP, this creates a simple hashed API key.
    In production, consider using more sophisticated token management.
    
    Args:
        user_id: User identifier
        
    Returns:
        API key string
    """
    # Create a random token
    random_token = secrets.token_urlsafe(32)
    
    # Combine with user_id and salt for uniqueness
    key_material = f"{user_id}:{random_token}:{settings.API_KEY_SALT}"
    
    # Hash the key material
    api_key = hashlib.sha256(key_material.encode()).hexdigest()
    
    return api_key


def extract_user_id_from_api_key(api_key: str) -> str:
    """
    Extract user ID from API key
    
    For MVP, we use a simple format: {user_id}:{api_key}
    
    Args:
        api_key: API key in format "user_id:key"
        
    Returns:
        User ID
        
    Raises:
        HTTPException: If API key format is invalid
    """
    try:
        if ":" in api_key:
            user_id, _ = api_key.split(":", 1)
            return user_id
        else:
            raise ValueError("Invalid API key format")
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API key format. Expected format: user_id:key"
        )


async def verify_api_key(x_api_key: str = Header(..., description="API Key for authentication")) -> str:
    """
    Verify API key from request header
    
    This is a FastAPI dependency that can be used in route handlers.
    
    Args:
        x_api_key: API key from X-API-Key header
        
    Returns:
        User ID extracted from API key
        
    Raises:
        HTTPException: If API key is invalid
        
    Example:
        @app.get("/items")
        async def get_items(user_id: str = Depends(verify_api_key)):
            # user_id is automatically extracted and verified
            ...
    """
    if not x_api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API key is required. Please provide X-API-Key header."
        )
    
    # Extract user ID from API key
    user_id = extract_user_id_from_api_key(x_api_key)
    
    # For MVP, we trust the API key format
    # In production, you would validate against a database
    
    return user_id

