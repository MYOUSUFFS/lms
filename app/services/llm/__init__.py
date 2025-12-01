"""
LMS RAG Backend - LLM Service
Local-first LLM with Ollama + Cloud fallback (Groq/Together)
"""

from abc import ABC, abstractmethod
from typing import AsyncGenerator, Optional

import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


# ===========================================
# Base LLM Provider
# ===========================================

class BaseLLMProvider(ABC):
    """Abstract base class for LLM providers."""
    
    @abstractmethod
    async def generate(self, prompt: str, system_prompt: str = None) -> str:
        """Generate a response from the LLM."""
        pass
    
    @abstractmethod
    async def generate_stream(self, prompt: str, system_prompt: str = None) -> AsyncGenerator[str, None]:
        """Generate a streaming response from the LLM."""
        pass
    
    @abstractmethod
    async def is_available(self) -> bool:
        """Check if the provider is available."""
        pass


# ===========================================
# Ollama Provider (Local)
# ===========================================

class OllamaProvider(BaseLLMProvider):
    """Ollama local LLM provider."""
    
    def __init__(
        self,
        base_url: str = None,
        model: str = None,
        timeout: int = 120,
    ):
        self.base_url = (base_url or settings.ollama_base_url).rstrip("/")
        self.model = model or settings.ollama_model
        self.timeout = timeout
        self.client = httpx.AsyncClient(timeout=timeout)
        
        logger.info(f"Ollama provider initialized: {self.base_url}, model: {self.model}")
    
    async def is_available(self) -> bool:
        """Check if Ollama is running."""
        try:
            response = await self.client.get(f"{self.base_url}/api/tags")
            return response.status_code == 200
        except Exception as e:
            logger.debug(f"Ollama not available: {e}")
            return False
    
    async def generate(self, prompt: str, system_prompt: str = None) -> str:
        """Generate response using Ollama."""
        messages = []
        
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "stream": False,
        }
        
        try:
            response = await self.client.post(
                f"{self.base_url}/api/chat",
                json=payload,
            )
            response.raise_for_status()
            
            data = response.json()
            return data.get("message", {}).get("content", "")
            
        except Exception as e:
            logger.error(f"Ollama generation error: {e}")
            raise
    
    async def generate_stream(self, prompt: str, system_prompt: str = None) -> AsyncGenerator[str, None]:
        """Generate streaming response using Ollama."""
        messages = []
        
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "stream": True,
        }
        
        try:
            async with self.client.stream(
                "POST",
                f"{self.base_url}/api/chat",
                json=payload,
            ) as response:
                async for line in response.aiter_lines():
                    if line:
                        import json
                        data = json.loads(line)
                        content = data.get("message", {}).get("content", "")
                        if content:
                            yield content
        except Exception as e:
            logger.error(f"Ollama streaming error: {e}")
            raise


# ===========================================
# Groq Provider (Cloud)
# ===========================================

class GroqProvider(BaseLLMProvider):
    """Groq cloud LLM provider."""
    
    BASE_URL = "https://api.groq.com/openai/v1"
    
    def __init__(
        self,
        api_key: str = None,
        model: str = None,
        timeout: int = 60,
    ):
        self.api_key = api_key or settings.groq_api_key
        self.model = model or settings.groq_model
        self.timeout = timeout
        self.client = httpx.AsyncClient(
            timeout=timeout,
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            }
        )
        
        logger.info(f"Groq provider initialized: model {self.model}")
    
    async def is_available(self) -> bool:
        """Check if Groq is available (has API key)."""
        return bool(self.api_key)
    
    async def generate(self, prompt: str, system_prompt: str = None) -> str:
        """Generate response using Groq."""
        messages = []
        
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 2048,
        }
        
        try:
            response = await self.client.post(
                f"{self.BASE_URL}/chat/completions",
                json=payload,
            )
            response.raise_for_status()
            
            data = response.json()
            return data["choices"][0]["message"]["content"]
            
        except Exception as e:
            logger.error(f"Groq generation error: {e}")
            raise
    
    async def generate_stream(self, prompt: str, system_prompt: str = None) -> AsyncGenerator[str, None]:
        """Generate streaming response using Groq."""
        messages = []
        
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 2048,
            "stream": True,
        }
        
        try:
            async with self.client.stream(
                "POST",
                f"{self.BASE_URL}/chat/completions",
                json=payload,
            ) as response:
                async for line in response.aiter_lines():
                    if line.startswith("data: "):
                        data_str = line[6:]
                        if data_str.strip() == "[DONE]":
                            break
                        import json
                        data = json.loads(data_str)
                        content = data["choices"][0].get("delta", {}).get("content", "")
                        if content:
                            yield content
        except Exception as e:
            logger.error(f"Groq streaming error: {e}")
            raise


# ===========================================
# Together AI Provider (Cloud)
# ===========================================

class TogetherProvider(BaseLLMProvider):
    """Together AI cloud LLM provider."""
    
    BASE_URL = "https://api.together.xyz/v1"
    
    def __init__(
        self,
        api_key: str = None,
        model: str = None,
        timeout: int = 60,
    ):
        self.api_key = api_key or settings.together_api_key
        self.model = model or settings.together_model
        self.timeout = timeout
        self.client = httpx.AsyncClient(
            timeout=timeout,
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            }
        )
        
        logger.info(f"Together provider initialized: model {self.model}")
    
    async def is_available(self) -> bool:
        """Check if Together AI is available."""
        return bool(self.api_key)
    
    async def generate(self, prompt: str, system_prompt: str = None) -> str:
        """Generate response using Together AI."""
        messages = []
        
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 2048,
        }
        
        try:
            response = await self.client.post(
                f"{self.BASE_URL}/chat/completions",
                json=payload,
            )
            response.raise_for_status()
            
            data = response.json()
            return data["choices"][0]["message"]["content"]
            
        except Exception as e:
            logger.error(f"Together AI generation error: {e}")
            raise
    
    async def generate_stream(self, prompt: str, system_prompt: str = None) -> AsyncGenerator[str, None]:
        """Generate streaming response using Together AI."""
        messages = []
        
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        
        messages.append({"role": "user", "content": prompt})
        
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 2048,
            "stream": True,
        }
        
        try:
            async with self.client.stream(
                "POST",
                f"{self.BASE_URL}/chat/completions",
                json=payload,
            ) as response:
                async for line in response.aiter_lines():
                    if line.startswith("data: "):
                        data_str = line[6:]
                        if data_str.strip() == "[DONE]":
                            break
                        import json
                        data = json.loads(data_str)
                        content = data["choices"][0].get("delta", {}).get("content", "")
                        if content:
                            yield content
        except Exception as e:
            logger.error(f"Together AI streaming error: {e}")
            raise


# ===========================================
# LLM Service (Orchestrator)
# ===========================================

class LLMService:
    """
    LLM Service with local-first approach and cloud fallback.
    
    Priority:
    1. Ollama (local) - Primary
    2. Groq/Together (cloud) - Fallback
    """
    
    # Default RAG system prompt
    DEFAULT_SYSTEM_PROMPT = """You are a helpful AI assistant for a Learning Management System. 
Your task is to answer questions based on the provided context from course materials and documents.

Instructions:
- Base your answers on the provided context
- If the context doesn't contain relevant information, say so clearly
- Be concise but comprehensive
- Cite sources when possible (mention document names or page numbers)
- If asked about something not in the context, acknowledge the limitation

Context will be provided in the user's message."""
    
    def __init__(self):
        """Initialize LLM service with all providers."""
        self.ollama = OllamaProvider()
        self.groq = GroqProvider()
        self.together = TogetherProvider()
        
        self._active_provider: Optional[BaseLLMProvider] = None
        self._active_provider_name: str = ""
        
        logger.info("LLM Service initialized")
    
    async def get_provider(self) -> tuple[BaseLLMProvider, str]:
        """
        Get the best available provider.
        
        Returns:
            Tuple of (provider, provider_name)
        """
        # Try Ollama first (local)
        if await self.ollama.is_available():
            return self.ollama, f"ollama:{settings.ollama_model}"
        
        # Fallback to cloud if enabled
        if settings.use_cloud_fallback:
            if settings.cloud_provider == "groq" and await self.groq.is_available():
                return self.groq, f"groq:{settings.groq_model}"
            
            if settings.cloud_provider == "together" and await self.together.is_available():
                return self.together, f"together:{settings.together_model}"
            
            # Try other cloud provider if preferred is not available
            if await self.groq.is_available():
                return self.groq, f"groq:{settings.groq_model}"
            
            if await self.together.is_available():
                return self.together, f"together:{settings.together_model}"
        
        raise RuntimeError("No LLM provider available. Start Ollama or configure cloud API keys.")
    
    @retry(stop=stop_after_attempt(2), wait=wait_exponential(multiplier=1, min=1, max=10))
    async def generate(
        self,
        prompt: str,
        system_prompt: str = None,
        context: str = None,
    ) -> tuple[str, str]:
        """
        Generate a response.
        
        Args:
            prompt: User prompt/question
            system_prompt: Optional system prompt
            context: Optional RAG context to include
            
        Returns:
            Tuple of (response, model_used)
        """
        provider, provider_name = await self.get_provider()
        
        # Build full prompt with context
        full_prompt = prompt
        if context:
            full_prompt = f"""Context:
{context}

Question: {prompt}

Please answer based on the context provided above."""
        
        system = system_prompt or self.DEFAULT_SYSTEM_PROMPT
        
        logger.info(f"Generating response with {provider_name}")
        
        try:
            response = await provider.generate(full_prompt, system)
            return response, provider_name
        except Exception as e:
            logger.warning(f"Provider {provider_name} failed: {e}")
            # Try fallback
            if provider == self.ollama and settings.use_cloud_fallback:
                fallback, fallback_name = await self._get_cloud_fallback()
                if fallback:
                    response = await fallback.generate(full_prompt, system)
                    return response, fallback_name
            raise
    
    async def generate_stream(
        self,
        prompt: str,
        system_prompt: str = None,
        context: str = None,
    ) -> AsyncGenerator[tuple[str, str], None]:
        """
        Generate a streaming response.
        
        Args:
            prompt: User prompt
            system_prompt: Optional system prompt
            context: Optional RAG context
            
        Yields:
            Tuple of (chunk, model_used)
        """
        provider, provider_name = await self.get_provider()
        
        full_prompt = prompt
        if context:
            full_prompt = f"""Context:
{context}

Question: {prompt}

Please answer based on the context provided above."""
        
        system = system_prompt or self.DEFAULT_SYSTEM_PROMPT
        
        async for chunk in provider.generate_stream(full_prompt, system):
            yield chunk, provider_name
    
    async def _get_cloud_fallback(self) -> tuple[Optional[BaseLLMProvider], str]:
        """Get available cloud fallback provider."""
        if await self.groq.is_available():
            return self.groq, f"groq:{settings.groq_model}"
        if await self.together.is_available():
            return self.together, f"together:{settings.together_model}"
        return None, ""
    
    async def health_check(self) -> dict:
        """Check health of all providers."""
        return {
            "ollama": {
                "available": await self.ollama.is_available(),
                "model": settings.ollama_model,
                "url": settings.ollama_base_url,
            },
            "groq": {
                "available": await self.groq.is_available(),
                "model": settings.groq_model,
                "configured": bool(settings.groq_api_key),
            },
            "together": {
                "available": await self.together.is_available(),
                "model": settings.together_model,
                "configured": bool(settings.together_api_key),
            },
        }


# Global singleton
_llm_service: Optional[LLMService] = None


def get_llm_service() -> LLMService:
    """Get or create LLM service singleton."""
    global _llm_service
    if _llm_service is None:
        _llm_service = LLMService()
    return _llm_service
