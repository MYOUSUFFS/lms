"""
LMS RAG Backend - LangChain Chat Service
Handles conversation memory and chat history automatically
"""

from typing import AsyncGenerator, Optional, Dict, List
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.output_parsers import StrOutputParser
from langchain_ollama import ChatOllama
from langchain.memory import ConversationBufferWindowMemory

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


# In-memory store for conversation sessions
_conversation_store: Dict[str, ConversationBufferWindowMemory] = {}


def get_or_create_memory(session_id: str, k: int = 20) -> ConversationBufferWindowMemory:
    """Get or create a conversation memory for a session."""
    if session_id not in _conversation_store:
        _conversation_store[session_id] = ConversationBufferWindowMemory(
            k=k,  # Keep last k exchanges
            return_messages=True,
            memory_key="chat_history",
        )
    return _conversation_store[session_id]


def clear_memory(session_id: str) -> None:
    """Clear conversation memory for a session."""
    if session_id in _conversation_store:
        del _conversation_store[session_id]


class LangChainChatService:
    """
    Chat service using LangChain for conversation memory.
    Supports Ollama (local) with automatic memory management.
    """
    
    DEFAULT_SYSTEM_PROMPT = """You are a helpful AI assistant. 

Instructions:
- Provide clear, accurate, and concise answers
- If you don't know something, say so honestly
- Use examples when helpful
- Format code properly with markdown code blocks
- Be friendly and professional
- Remember the conversation history and refer back to previous messages when relevant
- If the user asks about previous questions or messages, look at the chat history to answer accurately"""
    
    def __init__(self):
        """Initialize LangChain chat service."""
        self.model_name = settings.ollama_model
        self.base_url = settings.ollama_base_url
        
        # Initialize Ollama LLM
        self.llm = ChatOllama(
            model=self.model_name,
            base_url=self.base_url,
            temperature=0.7,
        )
        
        # Create prompt template with memory placeholder
        self.prompt = ChatPromptTemplate.from_messages([
            ("system", "{system_prompt}"),
            MessagesPlaceholder(variable_name="chat_history"),
            ("human", "{input}"),
        ])
        
        # Create the chain
        self.chain = self.prompt | self.llm | StrOutputParser()
        
        logger.info(f"LangChain Chat Service initialized with {self.model_name}")
    
    async def chat(
        self,
        message: str,
        session_id: str,
        system_prompt: Optional[str] = None,
    ) -> tuple[str, str]:
        """
        Send a chat message with automatic memory management.
        
        Args:
            message: User's message
            session_id: Unique session/conversation ID
            system_prompt: Optional custom system prompt
            
        Returns:
            Tuple of (response, model_used)
        """
        memory = get_or_create_memory(session_id)
        
        # Get chat history
        chat_history = memory.load_memory_variables({}).get("chat_history", [])
        
        try:
            # Generate response
            response = await self.chain.ainvoke({
                "system_prompt": system_prompt or self.DEFAULT_SYSTEM_PROMPT,
                "chat_history": chat_history,
                "input": message,
            })
            
            # Save to memory
            memory.save_context(
                {"input": message},
                {"output": response}
            )
            
            return response, f"ollama:{self.model_name}"
            
        except Exception as e:
            logger.error(f"LangChain chat error: {e}")
            raise
    
    async def chat_stream(
        self,
        message: str,
        session_id: str,
        system_prompt: Optional[str] = None,
    ) -> AsyncGenerator[str, None]:
        """
        Stream a chat response with automatic memory management.
        
        Args:
            message: User's message
            session_id: Unique session/conversation ID
            system_prompt: Optional custom system prompt
            
        Yields:
            Response chunks
        """
        memory = get_or_create_memory(session_id)
        
        # Get chat history
        chat_history = memory.load_memory_variables({}).get("chat_history", [])
        
        full_response = ""
        
        try:
            # Stream response
            async for chunk in self.chain.astream({
                "system_prompt": system_prompt or self.DEFAULT_SYSTEM_PROMPT,
                "chat_history": chat_history,
                "input": message,
            }):
                full_response += chunk
                yield chunk
            
            # Save to memory after streaming completes
            memory.save_context(
                {"input": message},
                {"output": full_response}
            )
            
        except Exception as e:
            logger.error(f"LangChain streaming error: {e}")
            raise
    
    def chat_with_history(
        self,
        message: str,
        conversation_history: List[Dict[str, str]],
        system_prompt: Optional[str] = None,
    ) -> tuple[str, str]:
        """
        Chat with externally provided conversation history.
        Useful when history is managed by the client (Flutter app).
        
        Args:
            message: User's message
            conversation_history: List of {"role": "user"|"assistant", "content": "..."}
            system_prompt: Optional custom system prompt
            
        Returns:
            Tuple of (response, model_used)
        """
        # Convert history to LangChain messages
        chat_history = []
        for msg in conversation_history:
            if msg["role"] == "user":
                chat_history.append(HumanMessage(content=msg["content"]))
            else:
                chat_history.append(AIMessage(content=msg["content"]))
        
        try:
            # Generate response synchronously
            response = self.chain.invoke({
                "system_prompt": system_prompt or self.DEFAULT_SYSTEM_PROMPT,
                "chat_history": chat_history,
                "input": message,
            })
            
            return response, f"ollama:{self.model_name}"
            
        except Exception as e:
            logger.error(f"LangChain chat error: {e}")
            raise
    
    async def chat_with_history_async(
        self,
        message: str,
        conversation_history: List[Dict[str, str]],
        system_prompt: Optional[str] = None,
    ) -> tuple[str, str]:
        """
        Async chat with externally provided conversation history.
        """
        # Convert history to LangChain messages
        chat_history = []
        for msg in conversation_history:
            if msg["role"] == "user":
                chat_history.append(HumanMessage(content=msg["content"]))
            else:
                chat_history.append(AIMessage(content=msg["content"]))
        
        try:
            response = await self.chain.ainvoke({
                "system_prompt": system_prompt or self.DEFAULT_SYSTEM_PROMPT,
                "chat_history": chat_history,
                "input": message,
            })
            
            return response, f"ollama:{self.model_name}"
            
        except Exception as e:
            logger.error(f"LangChain chat error: {e}")
            raise
    
    async def chat_stream_with_history(
        self,
        message: str,
        conversation_history: List[Dict[str, str]],
        system_prompt: Optional[str] = None,
    ) -> AsyncGenerator[str, None]:
        """
        Stream chat with externally provided conversation history.
        """
        # Convert history to LangChain messages
        chat_history = []
        for msg in conversation_history:
            if msg["role"] == "user":
                chat_history.append(HumanMessage(content=msg["content"]))
            else:
                chat_history.append(AIMessage(content=msg["content"]))
        
        try:
            async for chunk in self.chain.astream({
                "system_prompt": system_prompt or self.DEFAULT_SYSTEM_PROMPT,
                "chat_history": chat_history,
                "input": message,
            }):
                yield chunk
                
        except Exception as e:
            logger.error(f"LangChain streaming error: {e}")
            raise
    
    def get_chat_history(self, session_id: str) -> List[Dict[str, str]]:
        """Get the chat history for a session."""
        memory = get_or_create_memory(session_id)
        messages = memory.load_memory_variables({}).get("chat_history", [])
        
        history = []
        for msg in messages:
            if isinstance(msg, HumanMessage):
                history.append({"role": "user", "content": msg.content})
            elif isinstance(msg, AIMessage):
                history.append({"role": "assistant", "content": msg.content})
        
        return history
    
    async def is_available(self) -> bool:
        """Check if Ollama is available."""
        import httpx
        try:
            async with httpx.AsyncClient(timeout=5) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                return response.status_code == 200
        except Exception:
            return False


# Global singleton
_langchain_chat_service: Optional[LangChainChatService] = None


def get_langchain_chat_service() -> LangChainChatService:
    """Get or create LangChain chat service singleton."""
    global _langchain_chat_service
    if _langchain_chat_service is None:
        _langchain_chat_service = LangChainChatService()
    return _langchain_chat_service
