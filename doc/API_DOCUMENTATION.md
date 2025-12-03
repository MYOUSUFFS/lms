# LMS RAG Backend API - Complete Documentation

## Overview
This is a comprehensive guide for all API endpoints in the LMS RAG Backend. All endpoints (except health check) require an `X-API-Key` header.

---

## 📋 Table of Contents
1. [Base URL & Authentication](#base-url--authentication)
2. [Health & Status Endpoints](#health--status-endpoints)
3. [Documents Endpoints](#documents-endpoints)
4. [Query & Search Endpoints](#query--search-endpoints)
5. [Chat & Conversation Endpoints](#chat--conversation-endpoints)
6. [Error Handling](#error-handling)

---

## Base URL & Authentication

### Base URL
```
http://localhost:8000/api/v1
```

### Authentication
All endpoints (except `/health`, `/stats`, `/`) require the `X-API-Key` header:

```
X-API-Key: your-api-key-here
```

### Variables for Postman
Set these variables in your Postman environment:
- `base_url`: `http://localhost:8000/api/v1`
- `api_key`: Your actual API key

---

## 🏥 Health & Status Endpoints

### 1. Health Check
**Endpoint:** `GET /health`

**Authentication:** Not required

**Description:** Comprehensive health check for all system components (Vector Store, LLM, Embeddings)

**Example Request:**
```bash
curl -X GET http://localhost:8000/health
```

**Example Response (200):**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00",
  "components": {
    "vector_store": {
      "status": "healthy",
      "type": "chromadb",
      "documents_count": 15,
      "latency_ms": 45.23
    },
    "llm": {
      "status": "healthy",
      "available_models": ["llama2", "mistral"],
      "current_model": "llama2",
      "provider": "ollama",
      "latency_ms": 120.5
    },
    "embeddings": {
      "status": "healthy",
      "model": "bge-base-en-v1.5",
      "latency_ms": 89.3
    }
  }
}
```

---

### 2. Root Info
**Endpoint:** `GET /`

**Authentication:** Not required

**Description:** Get basic API information and available endpoints

**Example Request:**
```bash
curl -X GET http://localhost:8000/
```

**Example Response (200):**
```json
{
  "name": "LMS RAG Backend API",
  "version": "1.0.0",
  "status": "running",
  "docs": "/docs",
  "health": "/health"
}
```

---

### 3. System Statistics
**Endpoint:** `GET /stats`

**Authentication:** Required (X-API-Key)

**Description:** Get system statistics and usage information

**Example Request:**
```bash
curl -X GET http://localhost:8000/api/v1/stats \
  -H "X-API-Key: your-api-key-here"
```

**Example Response (200):**
```json
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

## 📄 Documents Endpoints

### 1. Upload Document
**Endpoint:** `POST /documents/upload`

**Authentication:** Required (X-API-Key)

**Content-Type:** `multipart/form-data`

**Description:** Upload and process a document (PDF, TXT, HTML, CSV, or image for OCR)

**Supported Formats:**
- PDF (.pdf)
- Text (.txt, .md)
- HTML (.html, .htm)
- CSV/Excel (.csv, .xlsx, .xls)
- Images for OCR (.png, .jpg, .jpeg)

**Request Parameters:**
- `file` (required): Document file to upload
- `document_id` (optional): Custom document ID

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/v1/documents/upload \
  -H "X-API-Key: your-api-key-here" \
  -F "file=@/path/to/document.pdf" \
  -F "document_id=doc_001"
```

**Example Response (201):**
```json
{
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "filename": "document.pdf",
  "document_type": "pdf",
  "status": "completed",
  "message": "Document processed successfully",
  "chunks_created": 42
}
```

**Error Response (400):**
```json
{
  "detail": "Unsupported file type: exe. Allowed: pdf,txt,md,html,htm,csv,xlsx,xls,png,jpg,jpeg"
}
```

---

### 2. Scrape URL
**Endpoint:** `POST /documents/scrape`

**Authentication:** Required (X-API-Key)

**Content-Type:** `application/json`

**Description:** Scrape content from a URL and add to the knowledge base

**Request Body:**
```json
{
  "url": "https://example.com/article",
  "extract_links": false,
  "max_depth": 1
}
```

**Request Parameters:**
- `url` (required): URL to scrape
- `extract_links` (optional, default: false): Extract and follow links
- `max_depth` (optional, default: 1): Maximum crawl depth (1-3)

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/v1/documents/scrape \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/article",
    "extract_links": false,
    "max_depth": 1
  }'
```

**Example Response (201):**
```json
{
  "url": "https://example.com/article",
  "document_id": "550e8400-e29b-41d4-a716-446655440001",
  "title": "Example Article Title",
  "status": "completed",
  "chunks_created": 28,
  "message": "URL scraped and processed successfully"
}
```

---

### 3. List All Documents
**Endpoint:** `GET /documents`

**Authentication:** Required (X-API-Key)

**Description:** Get a list of all documents in the knowledge base

**Example Request:**
```bash
curl -X GET http://localhost:8000/api/v1/documents \
  -H "X-API-Key: your-api-key-here"
```

**Example Response (200):**
```json
{
  "documents": [
    {
      "document_id": "550e8400-e29b-41d4-a716-446655440000",
      "filename": "python_guide.pdf",
      "document_type": "pdf",
      "status": "completed",
      "chunks_count": 42,
      "created_at": "2024-01-15T10:15:00",
      "file_size_bytes": 2048576
    },
    {
      "document_id": "550e8400-e29b-41d4-a716-446655440001",
      "filename": "tutorial.txt",
      "document_type": "txt",
      "status": "completed",
      "chunks_count": 18,
      "created_at": "2024-01-15T11:30:00",
      "file_size_bytes": 512000
    }
  ],
  "total": 2
}
```

---

### 4. Get Document Info
**Endpoint:** `GET /documents/{document_id}`

**Authentication:** Required (X-API-Key)

**Description:** Get information about a specific document

**URL Parameters:**
- `document_id` (required): The document ID

**Example Request:**
```bash
curl -X GET http://localhost:8000/api/v1/documents/550e8400-e29b-41d4-a716-446655440000 \
  -H "X-API-Key: your-api-key-here"
```

**Example Response (200):**
```json
{
  "document_id": "550e8400-e29b-41d4-a716-446655440000",
  "filename": "python_guide.pdf",
  "document_type": "pdf",
  "status": "completed",
  "chunks_count": 42,
  "created_at": "2024-01-15T10:15:00",
  "file_size_bytes": 2048576
}
```

**Error Response (404):**
```json
{
  "detail": "Document not found: invalid-id"
}
```

---

### 5. Delete Document
**Endpoint:** `DELETE /documents/{document_id}`

**Authentication:** Required (X-API-Key)

**Description:** Delete a document from the knowledge base

**URL Parameters:**
- `document_id` (required): The document ID to delete

**Example Request:**
```bash
curl -X DELETE http://localhost:8000/api/v1/documents/550e8400-e29b-41d4-a716-446655440000 \
  -H "X-API-Key: your-api-key-here"
```

**Example Response (204):**
```
No content
```

---

## 🔍 Query & Search Endpoints

### 1. Query Knowledge Base
**Endpoint:** `POST /query`

**Authentication:** Required (X-API-Key)

**Content-Type:** `application/json`

**Description:** Ask a question and get an answer based on indexed documents

**Request Body:**
```json
{
  "query": "What is Python and what are its main features?",
  "top_k": 5,
  "include_sources": true,
  "document_ids": null
}
```

**Request Parameters:**
- `query` (required): User question (1-2000 characters)
- `top_k` (optional, default: 5): Number of context chunks to retrieve (1-20)
- `include_sources` (optional, default: true): Include source documents in response
- `document_ids` (optional): Filter by specific document IDs

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/v1/query \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is Python and what are its main features?",
    "top_k": 5,
    "include_sources": true
  }'
```

**Example Response (200):**
```json
{
  "query": "What is Python and what are its main features?",
  "answer": "Python is a high-level, interpreted programming language known for its simplicity and readability. Main features include: 1) Easy-to-learn syntax that emphasizes code readability, 2) Dynamic typing, 3) Comprehensive standard library, 4) Support for multiple programming paradigms (OOP, functional, procedural), 5) Cross-platform compatibility, 6) Strong community support.",
  "sources": [
    {
      "document_id": "550e8400-e29b-41d4-a716-446655440000",
      "filename": "python_guide.pdf",
      "chunk_id": "chunk_001",
      "content": "Python is a high-level, interpreted programming language. It was created by Guido van Rossum and first released in 1991. Python's design philosophy emphasizes code readability with the use of significant indentation...",
      "similarity_score": 0.9234,
      "page_number": 1
    }
  ],
  "model_used": "llama2",
  "processing_time_ms": 1234.56
}
```

---

### 2. Query with Streaming
**Endpoint:** `POST /query/stream`

**Authentication:** Required (X-API-Key)

**Content-Type:** `application/json`

**Description:** Query with streaming LLM response

**Request Body:**
```json
{
  "query": "Explain the concept of decorators in Python",
  "top_k": 3,
  "include_sources": false
}
```

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/v1/query/stream \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Explain decorators in Python",
    "top_k": 3,
    "include_sources": false
  }'
```

**Example Response (200 - text/plain):**
```
Decorators in Python are functions that modify the behavior of other functions or classes. They wrap a function with additional functionality without permanently modifying the original function. Here's how they work:

1. A decorator is a function that takes another function as an argument
2. It returns a new function that usually calls the original function
3. The new function can add code before and/or after the original function

Example:
@my_decorator
def my_function():
    pass

This is equivalent to:
my_function = my_decorator(my_function)
```

---

### 3. Search Only (No LLM)
**Endpoint:** `POST /query/search`

**Authentication:** Required (X-API-Key)

**Content-Type:** `application/json`

**Description:** Search for relevant documents without LLM generation

**Request Body:**
```json
{
  "query": "machine learning algorithms",
  "top_k": 10,
  "include_sources": true,
  "document_ids": ["550e8400-e29b-41d4-a716-446655440002"]
}
```

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/v1/query/search \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "machine learning algorithms",
    "top_k": 10,
    "include_sources": true
  }'
```

**Example Response (200):**
```json
{
  "query": "machine learning algorithms",
  "results": [
    {
      "chunk_id": "ml_chunk_001",
      "content": "Machine learning algorithms are computational methods that allow systems to learn and improve from experience. Major categories include supervised learning, unsupervised learning, and reinforcement learning...",
      "metadata": {
        "document_id": "550e8400-e29b-41d4-a716-446655440002",
        "filename": "ml_guide.pdf",
        "page_number": 12
      },
      "similarity_score": 0.9567
    }
  ],
  "total": 1
}
```

---

## 💬 Chat & Conversation Endpoints

### 1. Chat with Client-side History
**Endpoint:** `POST /chat`

**Authentication:** Required (X-API-Key)

**Content-Type:** `application/json`

**Description:** Chat with AI that remembers conversation history (client-side)

**Request Body:**
```json
{
  "message": "Can you summarize what we discussed about Python?",
  "conversation_history": [
    {
      "role": "user",
      "content": "What is Python?"
    },
    {
      "role": "assistant",
      "content": "Python is a high-level programming language..."
    }
  ],
  "session_id": null,
  "system_prompt": null
}
```

**Request Parameters:**
- `message` (required): Current message (1-5000 characters)
- `conversation_history` (optional): Previous messages for context
  - Each message has `role` (user/assistant) and `content`
- `session_id` (optional): For server-side memory (use instead of history)
- `system_prompt` (optional): Custom system prompt

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Can you summarize what we discussed?",
    "conversation_history": [
      {"role": "user", "content": "What is Python?"},
      {"role": "assistant", "content": "Python is a high-level programming language..."}
    ]
  }'
```

**Example Response (200):**
```json
{
  "message": "Can you summarize what we discussed about Python?",
  "answer": "Of course! We discussed the following about Python: 1) Python is a high-level programming language, 2) It's known for its simplicity and readability, 3) Key features include easy syntax, dynamic typing, comprehensive standard library, and strong community support.",
  "model_used": "llama2",
  "processing_time_ms": 1567.89
}
```

---

### 2. Chat with Server-side Session
**Endpoint:** `POST /chat`

**Authentication:** Required (X-API-Key)

**Content-Type:** `application/json`

**Description:** Chat with server-side memory (uses session_id)

**Request Body:**
```json
{
  "message": "What was my first question?",
  "session_id": "session_user_123",
  "conversation_history": null,
  "system_prompt": null
}
```

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What was my first question?",
    "session_id": "session_user_123"
  }'
```

**Example Response (200):**
```json
{
  "message": "What was my first question?",
  "answer": "Your first question in this session was: 'What is Python?'. You asked that at the beginning of our conversation, and we've been discussing Python's features, capabilities, and use cases ever since.",
  "model_used": "llama2",
  "processing_time_ms": 890.45
}
```

---

### 3. Chat Stream (Server-side Session)
**Endpoint:** `POST /chat/stream`

**Authentication:** Required (X-API-Key)

**Content-Type:** `application/json`

**Description:** Stream chat response with conversation memory

**Request Body:**
```json
{
  "message": "Explain the relationship between our previous discussions",
  "session_id": "session_user_123",
  "conversation_history": null,
  "system_prompt": "You are a helpful Python tutor. Provide clear, concise explanations."
}
```

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "X-API-Key: your-api-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Explain the relationship",
    "session_id": "session_user_123",
    "system_prompt": "You are a helpful tutor."
  }'
```

**Example Response (200 - text/plain):**
```
In our conversation, we've built a solid foundation of understanding about Python. First, we established what Python is - a high-level, easy-to-learn programming language. Then, we explored its key features like simple syntax, dynamic typing, and its rich standard library.

These foundational concepts connect to practical applications: the simplicity makes it great for beginners, the dynamic typing allows flexible coding, and the standard library provides ready-made tools for almost any task.

Understanding these relationships helps you appreciate why Python is so popular in fields like data science, web development, and automation.
```

---

### 4. Get Chat History
**Endpoint:** `GET /chat/history/{session_id}`

**Authentication:** Required (X-API-Key)

**Description:** Get the conversation history for a session

**URL Parameters:**
- `session_id` (required): The session ID

**Example Request:**
```bash
curl -X GET http://localhost:8000/api/v1/chat/history/session_user_123 \
  -H "X-API-Key: your-api-key-here"
```

**Example Response (200):**
```json
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
      "content": "Python is a high-level programming language...",
      "timestamp": "2024-01-15T10:00:15"
    }
  ]
}
```

---

### 5. Clear Session Memory
**Endpoint:** `DELETE /chat/memory/{session_id}`

**Authentication:** Required (X-API-Key)

**Description:** Clear the conversation memory for a session

**URL Parameters:**
- `session_id` (required): The session ID to clear

**Example Request:**
```bash
curl -X DELETE http://localhost:8000/api/v1/chat/memory/session_user_123 \
  -H "X-API-Key: your-api-key-here"
```

**Example Response (200):**
```json
{
  "status": "ok",
  "message": "Memory cleared for session session_user_123"
}
```

---

## ⚠️ Error Handling

### Common HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | OK - Request successful | Query returned results |
| 201 | Created - Resource created | Document uploaded |
| 204 | No Content - Success with no body | Document deleted |
| 400 | Bad Request - Invalid input | Unsupported file type |
| 401 | Unauthorized - Missing/invalid API key | Missing X-API-Key header |
| 404 | Not Found - Resource doesn't exist | Document ID not found |
| 503 | Service Unavailable | LLM not running |

### Error Response Format
```json
{
  "detail": "Error description here"
}
```

### Common Error Scenarios

**Missing API Key:**
```
Status: 403 Forbidden
{
  "detail": "Not authenticated"
}
```

**LLM Not Available:**
```
Status: 503 Service Unavailable
{
  "detail": "LLM not available: Make sure Ollama is running."
}
```

**Invalid File Type:**
```
Status: 400 Bad Request
{
  "detail": "Unsupported file type: exe. Allowed: pdf,txt,md,html,htm,csv,xlsx,xls,png,jpg,jpeg"
}
```

---

## 🚀 Quick Start Examples

### 1. Upload a PDF and Query It
```bash
# Step 1: Upload document
DOC_ID=$(curl -X POST http://localhost:8000/api/v1/documents/upload \
  -H "X-API-Key: your-api-key" \
  -F "file=@guide.pdf" \
  | jq -r '.document_id')

# Step 2: Query the document
curl -X POST http://localhost:8000/api/v1/query \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d "{
    \"query\": \"What are the main topics?\",
    \"document_ids\": [\"$DOC_ID\"]
  }"
```

### 2. Start a Multi-turn Conversation
```bash
# Message 1
curl -X POST http://localhost:8000/api/v1/chat \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Tell me about Python",
    "session_id": "my_session"
  }'

# Message 2 (AI remembers previous context)
curl -X POST http://localhost:8000/api/v1/chat \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What did I ask before?",
    "session_id": "my_session"
  }'
```

---

## 📚 Integration Tips

### Postman Setup
1. Import the provided JSON collection
2. Set environment variables:
   - `base_url`: Your API base URL
   - `api_key`: Your API key
3. All endpoints will use these variables automatically

### Python Integration
```python
import requests

BASE_URL = "http://localhost:8000/api/v1"
API_KEY = "your-api-key"
HEADERS = {"X-API-Key": API_KEY}

# Query example
response = requests.post(
    f"{BASE_URL}/query",
    json={"query": "Your question here"},
    headers=HEADERS
)
print(response.json())
```

### JavaScript Integration
```javascript
const BASE_URL = "http://localhost:8000/api/v1";
const API_KEY = "your-api-key";

async function query(question) {
  const response = await fetch(`${BASE_URL}/query`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-API-Key": API_KEY
    },
    body: JSON.stringify({ query: question })
  });
  return response.json();
}
```

---

## 🔗 Important Links

- **API Docs (Swagger):** `http://localhost:8000/docs`
- **API Docs (ReDoc):** `http://localhost:8000/redoc`
- **OpenAPI Schema:** `http://localhost:8000/openapi.json`
- **Health Check:** `http://localhost:8000/health`

---

**Last Updated:** January 2024  
**API Version:** 1.0.0
