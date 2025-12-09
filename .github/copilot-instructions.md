# AI Copilot Instructions for LMS RAG Backend

## 🎯 Project Overview

This is a **Retrieval-Augmented Generation (RAG) Learning Management System** with a **Flutter** cross-platform client and **Python FastAPI** backend. The system enables AI-powered Q&A over uploaded documents using local-first LLM (Ollama) with cloud fallback (Groq/Together AI).

**Core Mission**: Enable semantic search over document knowledge bases with conversational memory and multi-format document support.

## 🏗️ Architecture at a Glance

### Two-Layer Architecture

1. **Frontend (Flutter)**: Cross-platform chat UI (iOS/Android/Web/macOS/Windows/Linux)

   - Location: `ai_chat_bot/lib/`
   - State management via **Provider** package
   - Two chat modes: RAG (document-based) and LangChain (memory-based)

2. **Backend (Python FastAPI)**: RAG pipeline + LLM orchestration
   - Location: `app/`
   - Modular service architecture: RAG pipeline, LLM providers, document processors

### The Two Query Flows

**RAG Flow** (document search):

```
Query → Embed → Vector Search (ChromaDB) → Context Retrieval → LLM → Answer
```

**Chat Flow** (conversational memory):

```
Message + History → LangChain Memory → LLM (with context) → Answer
```

## 🔑 Critical Components & Patterns

### Backend Services (Core Orchestrators)

**Singleton Pattern for Service Access** — Always use getters:

- `get_rag_pipeline()` — Access the main RAG orchestrator (`app/services/rag/pipeline.py`)
- `get_llm_service()` — Access LLM provider manager (`app/services/llm/__init__.py`)
- `get_langchain_chat_service()` — Access conversational memory service (`app/services/langchain_chat.py`)
- `get_vector_store()` — Access ChromaDB vector store (`app/services/rag/vector_store.py`)

These are **lazy-loaded singletons**. Never instantiate services directly.

### Document Ingestion Pipeline (`app/services/rag/pipeline.py`)

```python
RAGPipeline.ingest_file(path, document_id)  # Main entry point
# Internally: Process → Chunk → Embed → Store
```

**Key processors** in `app/services/processors/`:

- `PDFProcessor` — Uses PyMuPDF (fitz)
- `HTMLProcessor` — BeautifulSoup + lxml
- `OCRProcessor` — PaddleOCR for images
- `CSVProcessor` — pandas for tabular data

**Chunking strategy** (`app/services/rag/chunker.py`):

- Uses semantic sentence boundaries (not naive character splitting)
- Configurable via `.env`: `CHUNK_SIZE=1000`, `CHUNK_OVERLAP=200`
- Preserves document metadata for source attribution

### LLM Service (`app/services/llm/__init__.py`)

**Provider hierarchy** (tries each in order until available):

1. Ollama (local, primary) — Fastest, no cloud dependency
2. Groq API (fallback)
3. Together AI (fallback)

**How providers work**:

- All inherit from `BaseLLMProvider` abstract class
- Implement `generate()` and `generate_stream()` methods
- Async-first design using `httpx`
- Automatic retry logic via `tenacity` (exponential backoff)

**To add a new LLM provider**:

1. Create class inheriting `BaseLLMProvider` in `app/services/llm/__init__.py`
2. Implement `generate()`, `generate_stream()`, `is_available()`
3. Update `LLMService.get_provider()` to include in provider chain

### API Routes & Streaming

**Key endpoints** (`app/api/`):

- `POST /api/v1/query` — Single question over documents (returns answer + sources)
- `POST /api/v1/query/stream` — Streaming response (text/event-stream)
- `POST /api/v1/chat` — Chat with memory (client-side history)
- `POST /api/v1/chat/stream` — Streaming chat with memory
- `POST /api/v1/documents/upload` — Multipart upload (auto-processes)
- `POST /api/v1/documents/scrape` — URL scraping → processing
- `GET /api/v1/health` — System health check with component status

**Streaming Pattern** (used for large responses):

```python
async def query_stream(request):
    async def event_generator():
        async for chunk in llm_service.generate_stream(...):
            yield f"data: {chunk}\n\n"
    return StreamingResponse(event_generator(), media_type="text/event-stream")
```

## 🔌 Key Integration Points

### Configuration (`app/core/config.py`)

**Settings are environment-driven** via Pydantic:

```python
settings = Settings()  # Loads from .env automatically
```

**Essential vars to know**:

- `OLLAMA_BASE_URL`, `OLLAMA_MODEL` — Local LLM config
- `EMBEDDING_MODEL` — "BAAI/bge-large-en-v1.5" (multilingual)
- `CHROMA_PERSIST_DIRECTORY` — Vector DB path (default: `./data/chroma_db/`)
- `CHUNK_SIZE`, `CHUNK_OVERLAP` — Tuning chunking
- `API_KEY` — Required for all endpoints (header: `X-API-Key`)

### Security (`app/core/security.py`)

**All endpoints except `/health` require API key**:

```python
async def verify_api_key(request: Request) -> str:
    # Validates X-API-Key header against settings.api_key
```

### Vector Store (`app/services/rag/vector_store.py`)

- **Backend**: ChromaDB (persistent local SQLite + vector index)
- **Collections**: Organized by document metadata
- **Metadata stored per chunk**: `{document_id, filename, source_page, chunk_index}`
- **Lazy loading**: Models/embeddings only loaded on first query

## 📱 Flutter Frontend Patterns

### State Management (Provider Package)

**Three main providers** (`ai_chat_bot/lib/core/providers/`):

1. `ChatProvider` — Conversation state, message history
2. `SettingsProvider` — API config, theme, local storage
3. `DocumentProvider` — Document list, upload progress

**Usage pattern**:

```dart
final chatProvider = Provider.of<ChatProvider>(context);
```

### API Communication (`ai_chat_bot/lib/core/services/api_service.dart`)

**Key methods**:

- `sendChatMessage()` — Regular chat with memory
- `sendRagQuery()` — RAG query over documents
- `uploadDocument()` — Multipart upload
- `listDocuments()` — Fetch available docs
- **Streaming**: Uses `http.StreamedResponse` for real-time updates

**Authentication**: All requests include `X-API-Key` header

## 🛠️ Developer Workflows

### Local Development

```bash
# 1. Start Ollama (macOS)
brew services start ollama  # or: ollama serve

# 2. Pull a model
ollama pull llama3:8b

# 3. Backend
cd /Users/jdmobileapp/Project/lms
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 4. Flutter (in separate terminal)
cd ai_chat_bot
flutter run -d chrome  # or: ios/android/macos
```

**Verify setup**:

```bash
curl http://localhost:8000/api/v1/health -H "X-API-Key: change-me-in-production"
```

### Testing

**Backend tests** (Python):

```bash
pytest tests/  # Requires test fixtures
pytest --cov=app --cov-report=html  # Coverage report
```

**Test patterns**: Async fixtures with `pytest-asyncio`, mocked LLM providers

### Building & Deployment

**Docker**:

```bash
# Development (uses host Ollama)
docker-compose -f docker-compose.dev.yml up --build

# Production (includes Ollama)
docker-compose up -d --build
```

**Flutter builds**:

```bash
flutter build web    # Static site
flutter build apk    # Android
flutter build ios    # iOS
```

## 📋 Project-Specific Conventions

### File Organization Rules

- **API routes**: Each feature gets its own router in `app/api/` (e.g., `chat.py`, `documents.py`, `query.py`)
- **Services**: Business logic in `app/services/` with lazy-loaded singletons
- **Schemas**: All Pydantic models in `app/schemas/` (single source of truth for validation)
- **Processors**: Each document type gets dedicated processor class in `app/services/processors/`

### Async/Await Convention

- **Backend**: All I/O operations are `async` (LLM calls, embeddings, vector store queries)
- **Frontend**: Streaming handled via `http.StreamedResponse` in `api_service.dart`

### Logging

**Backend**:

```python
from app.core.logging import get_logger
logger = get_logger(__name__)
logger.info("Human-readable event message")
```

**Flutter**: Use `print()` or `debugPrint()` for dev, consider provider event logging for production

### Error Handling

**Backend**:

- Raise `HTTPException` with appropriate status codes
- Health checks report component status (not exceptions)
- Timeouts default to 120s for LLM calls (configurable)

**Frontend**:

- Wrap API calls in try/catch
- Provider notifies listeners of `isLoading` state
- Display user-friendly error messages

## 🔍 Common Tasks & How to Implement Them

### Adding a New Document Processor

1. Create class in `app/services/processors/__init__.py` inheriting `BaseProcessor`
2. Implement `process(file_path, document_id) → ProcessedDocument`
3. Register in `RAGPipeline.__init__()` processor map
4. Update `allowed_extensions` in `.env`

### Adding a New LLM Provider

1. Create `XyzProvider(BaseLLMProvider)` in `app/services/llm/__init__.py`
2. Implement `generate()`, `generate_stream()`, `is_available()`
3. Add config vars to `app/core/config.py`
4. Update `LLMService.get_provider()` chain

### Streaming a Response

Use the pattern in `app/api/query.py:query_stream()`:

```python
async def event_generator():
    async for chunk in pipeline.search_stream(query):
        yield f"data: {chunk}\n\n"
return StreamingResponse(event_generator(), media_type="text/event-stream")
```

### Modifying Vector Store Behavior

Edit `app/services/rag/vector_store.py` — changes propagate through:

- `RAGPipeline.search()` — Used by query endpoint
- `LangChainChatService` — Used by chat endpoint

## ⚠️ Gotchas & Edge Cases

1. **Embedding model loading** — BGE-Large is ~380MB on first download (happens in background, can cause timeouts)
2. **ChromaDB persistence** — Runs in-process SQLite, not distributed (production should consider Qdrant)
3. **Ollama availability** — System degrades gracefully to cloud fallback (Groq/Together) but will error if no provider available
4. **Document metadata** — Persists through chunks, critical for source attribution in responses
5. **API Key required** — All endpoints except `/health` require `X-API-Key` header (easy to miss in tests)

## 📚 Reading List

For understanding flow end-to-end:

1. `README.md` — High-level architecture and quick start
2. `app/main.py` — App initialization and middleware setup
3. `app/api/query.py` → `RAGPipeline.search()` — Trace a RAG query
4. `app/services/llm/__init__.py` → Provider selection logic
5. `app/services/rag/pipeline.py` — Full ingestion pipeline
6. `ai_chat_bot/lib/main.dart` → Provider setup
7. `ai_chat_bot/lib/core/services/api_service.dart` → Frontend API client

---

**Last Updated**: 2025-12-03  
**Backend Version**: 1.0.0  
**Flutter Version**: 3.8+
