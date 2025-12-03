# LMS RAG API - Quick Reference Guide

## 📌 Quick Summary

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/health` | GET | ❌ | Check system health |
| `/` | GET | ❌ | API info |
| `/stats` | GET | ✅ | System statistics |
| `/documents/upload` | POST | ✅ | Upload document |
| `/documents/scrape` | POST | ✅ | Scrape URL content |
| `/documents` | GET | ✅ | List all documents |
| `/documents/{id}` | GET | ✅ | Get document info |
| `/documents/{id}` | DELETE | ✅ | Delete document |
| `/query` | POST | ✅ | Query with RAG |
| `/query/stream` | POST | ✅ | Query with streaming |
| `/query/search` | POST | ✅ | Search only (no LLM) |
| `/chat` | POST | ✅ | Chat with memory |
| `/chat/stream` | POST | ✅ | Chat streaming |
| `/chat/history/{session_id}` | GET | ✅ | Get chat history |
| `/chat/memory/{session_id}` | DELETE | ✅ | Clear memory |

---

## 🔑 Authentication

All endpoints marked with ✅ require:
```
X-API-Key: your-api-key-here
```

---

## 📤 Documents - Examples

### Upload Document
```json
POST /documents/upload
Content-Type: multipart/form-data

file: <binary file>
document_id: doc_001 (optional)

RESPONSE:
{
  "document_id": "uuid",
  "filename": "file.pdf",
  "document_type": "pdf",
  "status": "completed",
  "chunks_created": 42
}
```

### Scrape URL
```json
POST /documents/scrape
Content-Type: application/json

{
  "url": "https://example.com",
  "extract_links": false,
  "max_depth": 1
}

RESPONSE:
{
  "url": "https://example.com",
  "document_id": "uuid",
  "title": "Page Title",
  "status": "completed",
  "chunks_created": 28
}
```

### List Documents
```json
GET /documents

RESPONSE:
{
  "documents": [
    {
      "document_id": "uuid",
      "filename": "file.pdf",
      "document_type": "pdf",
      "status": "completed",
      "chunks_count": 42,
      "created_at": "2024-01-15T10:15:00"
    }
  ],
  "total": 1
}
```

---

## 🔍 Query - Examples

### Basic Query
```json
POST /query
Content-Type: application/json

{
  "query": "What is Python?",
  "top_k": 5,
  "include_sources": true
}

RESPONSE:
{
  "query": "What is Python?",
  "answer": "Python is a high-level programming language...",
  "sources": [
    {
      "document_id": "uuid",
      "filename": "file.pdf",
      "chunk_id": "chunk_001",
      "content": "Python is...",
      "similarity_score": 0.92,
      "page_number": 1
    }
  ],
  "model_used": "llama2",
  "processing_time_ms": 1234.56
}
```

### Query Specific Documents
```json
POST /query
Content-Type: application/json

{
  "query": "Your question",
  "top_k": 5,
  "document_ids": ["doc_id_1", "doc_id_2"]
}
```

### Streaming Query
```json
POST /query/stream
Content-Type: application/json

{
  "query": "Explain decorators",
  "top_k": 3
}

RESPONSE: (text/plain - streams response word by word)
Decorators in Python are...
```

### Search Only (Raw Results)
```json
POST /query/search
Content-Type: application/json

{
  "query": "search term",
  "top_k": 10
}

RESPONSE:
{
  "query": "search term",
  "results": [
    {
      "chunk_id": "chunk_001",
      "content": "...content...",
      "similarity_score": 0.95
    }
  ],
  "total": 1
}
```

---

## 💬 Chat - Examples

### Chat Mode 1: Client-side History
```json
POST /chat
Content-Type: application/json

{
  "message": "Summarize what we discussed",
  "conversation_history": [
    {"role": "user", "content": "What is Python?"},
    {"role": "assistant", "content": "Python is..."}
  ]
}

RESPONSE:
{
  "message": "Summarize what we discussed",
  "answer": "We discussed Python, which is...",
  "model_used": "llama2",
  "processing_time_ms": 1567.89
}
```

### Chat Mode 2: Server-side Session
```json
POST /chat
Content-Type: application/json

{
  "message": "What was my first question?",
  "session_id": "session_user_123"
}

RESPONSE:
{
  "message": "What was my first question?",
  "answer": "Your first question was: What is Python?",
  "model_used": "llama2",
  "processing_time_ms": 890.45
}
```

### Streaming Chat
```json
POST /chat/stream
Content-Type: application/json

{
  "message": "Explain the concept",
  "session_id": "session_user_123"
}

RESPONSE: (text/plain - streams response)
Explaining the concept: ...
```

### Get Chat History
```json
GET /chat/history/session_user_123

RESPONSE:
{
  "session_id": "session_user_123",
  "history": [
    {
      "role": "user",
      "content": "What is Python?",
      "timestamp": "2024-01-15T10:00:00"
    },
    {
      "role": "assistant",
      "content": "Python is...",
      "timestamp": "2024-01-15T10:00:15"
    }
  ]
}
```

### Clear Session Memory
```json
DELETE /chat/memory/session_user_123

RESPONSE:
{
  "status": "ok",
  "message": "Memory cleared for session session_user_123"
}
```

---

## 🏥 Health & Status - Examples

### Health Check
```json
GET /health

RESPONSE:
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00",
  "components": {
    "vector_store": {
      "status": "healthy",
      "type": "chromadb",
      "documents_count": 15
    },
    "llm": {
      "status": "healthy",
      "current_model": "llama2"
    },
    "embeddings": {
      "status": "healthy",
      "model": "bge-base-en-v1.5"
    }
  }
}
```

### System Statistics
```json
GET /stats

RESPONSE:
{
  "documents": 15,
  "chunks": 342,
  "embedding_model": "bge-base-en-v1.5",
  "llm_model": "llama2",
  "chunk_size": 512,
  "chunk_overlap": 50
}
```

---

## 🛠️ cURL Examples

### 1. Health Check
```bash
curl -X GET http://localhost:8000/health
```

### 2. Upload PDF
```bash
curl -X POST http://localhost:8000/api/v1/documents/upload \
  -H "X-API-Key: your-api-key" \
  -F "file=@document.pdf"
```

### 3. Query
```bash
curl -X POST http://localhost:8000/api/v1/query \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"query": "What is Python?"}'
```

### 4. Chat
```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello",
    "session_id": "user_123"
  }'
```

### 5. Stream Query
```bash
curl -X POST http://localhost:8000/api/v1/query/stream \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"query": "Explain Python"}' \
  -N
```

---

## 📊 Request/Response Summary

### Supported File Types
- Documents: `pdf`, `txt`, `md`, `html`, `htm`, `csv`, `xlsx`, `xls`
- Images: `png`, `jpg`, `jpeg` (with OCR)

### Query Parameters
- `query`: 1-2000 characters
- `top_k`: 1-20 chunks (default: 5)
- `include_sources`: boolean (default: true)
- `document_ids`: array of IDs (optional filter)

### Chat Parameters
- `message`: 1-5000 characters
- `conversation_history`: array of message objects
  - `role`: "user" or "assistant"
  - `content`: message text
- `session_id`: for server-side memory
- `system_prompt`: custom prompt (optional)

---

## ❌ Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Missing/invalid API key | Add `X-API-Key` header |
| 400 Bad Request | Invalid file type | Use supported format |
| 404 Not Found | Document/session doesn't exist | Check ID is correct |
| 503 Service Unavailable | LLM not running | Start Ollama service |

---

## 🚀 Postman Setup

1. **Import Collection:**
   - File → Import → Select JSON file
   - Use `LMS_RAG_API_Postman_Collection.json`

2. **Set Environment Variables:**
   - Create new environment
   - Add `base_url`: `http://localhost:8000/api/v1`
   - Add `api_key`: Your API key

3. **Use Endpoints:**
   - All endpoints use variables automatically
   - Select environment before testing

---

## 💡 Tips & Tricks

### Streaming Responses
For streaming endpoints (`/query/stream`, `/chat/stream`), use `-N` flag in curl:
```bash
curl -N http://localhost:8000/api/v1/query/stream ...
```

### Filter by Document
When querying specific documents:
```json
{
  "query": "question",
  "document_ids": ["doc_id_1", "doc_id_2"]
}
```

### Custom System Prompt
For custom AI behavior:
```json
{
  "message": "question",
  "session_id": "user_123",
  "system_prompt": "You are a Python expert. Answer in short paragraphs."
}
```

### Save Query Results
Store results for later reference:
```bash
curl ... | jq . > query_result.json
```

---

## 🔗 Links

- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`
- **OpenAPI JSON:** `http://localhost:8000/openapi.json`

---

**Version:** 1.0.0  
**Last Updated:** January 2024
