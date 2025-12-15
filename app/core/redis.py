"""
Redis Service for Token Blacklist and Caching
"""

import redis.asyncio as redis
from typing import Optional
from datetime import timedelta

from app.core.config import Settings
from app.core.logging import get_logger

logger = get_logger(__name__)

settings = Settings()

# Global Redis connection pool
_redis_client: Optional[redis.Redis] = None


async def get_redis() -> redis.Redis:
    """Get Redis client instance (lazy-loaded singleton)"""
    global _redis_client
    
    if _redis_client is None:
        try:
            _redis_client = redis.from_url(
                settings.redis_url,
                password=settings.redis_password if settings.redis_password else None,
                encoding="utf-8",
                decode_responses=True,
                socket_connect_timeout=5,
                socket_keepalive=True,
            )
            # Test connection
            await _redis_client.ping()
            logger.info("Redis connection established")
        except Exception as e:
            logger.error(f"Failed to connect to Redis: {e}")
            raise
    
    return _redis_client


async def close_redis():
    """Close Redis connection"""
    global _redis_client
    if _redis_client:
        await _redis_client.close()
        _redis_client = None
        logger.info("Redis connection closed")


class TokenBlacklist:
    """Manages blacklisted tokens in Redis"""
    
    BLACKLIST_PREFIX = "token_blacklist:"
    
    @staticmethod
    async def add_token(token: str, expires_in_seconds: int):
        """
        Add a token to the blacklist
        
        Args:
            token: JWT token to blacklist
            expires_in_seconds: Time until token naturally expires
        """
        try:
            redis_client = await get_redis()
            key = f"{TokenBlacklist.BLACKLIST_PREFIX}{token}"
            
            # Store token with expiration matching its natural expiry
            await redis_client.setex(
                key,
                timedelta(seconds=expires_in_seconds),
                "1"
            )
            logger.info(f"Token added to blacklist (expires in {expires_in_seconds}s)")
        except Exception as e:
            logger.error(f"Failed to blacklist token: {e}")
            # Don't raise - allow logout to continue even if Redis fails
    
    @staticmethod
    async def is_blacklisted(token: str) -> bool:
        """
        Check if a token is blacklisted
        
        Args:
            token: JWT token to check
            
        Returns:
            True if token is blacklisted, False otherwise
        """
        try:
            redis_client = await get_redis()
            key = f"{TokenBlacklist.BLACKLIST_PREFIX}{token}"
            
            exists = await redis_client.exists(key)
            return bool(exists)
        except Exception as e:
            logger.error(f"Failed to check token blacklist: {e}")
            # Fail open - if Redis is down, allow the request
            return False
    
    @staticmethod
    async def remove_token(token: str):
        """
        Remove a token from the blacklist (rarely needed)
        
        Args:
            token: JWT token to remove
        """
        try:
            redis_client = await get_redis()
            key = f"{TokenBlacklist.BLACKLIST_PREFIX}{token}"
            await redis_client.delete(key)
            logger.info("Token removed from blacklist")
        except Exception as e:
            logger.error(f"Failed to remove token from blacklist: {e}")
