# How to Run the LMS RAG Backend

## Prerequisites

- **Python 3.10+** installed
- **Ollama** installed (for local LLM)
- Virtual environment set up with dependencies

---

## Step 1: Start Ollama (Local LLM)

### macOS

```bash
# Using Homebrew service
brew services start ollama

# Or run manually
ollama serve
```

### Pull a Model

```bash
ollama pull llama3:8b
```

> **Note:** The first model download is ~4GB and may take a few minutes.

---

## Step 2: Set Up Environment Variables

Create a `.env` file in the project root if it doesn't exist:

```bash
cp .env.example .env
```

### Key Environment Variables

| Variable          | Description                     | Default                   |
| ----------------- | ------------------------------- | ------------------------- |
| `API_KEY`         | Required for API authentication | `change-me-in-production` |
| `OLLAMA_BASE_URL` | Ollama server URL               | `http://localhost:11434`  |
| `OLLAMA_MODEL`    | LLM model to use                | `llama3:8b`               |
| `EMBEDDING_MODEL` | Embedding model                 | `BAAI/bge-large-en-v1.5`  |
| `CHUNK_SIZE`      | Document chunk size             | `1000`                    |
| `CHUNK_OVERLAP`   | Chunk overlap                   | `200`                     |

---

## Step 3: Run the Backend

### Option 1: Development Mode (with auto-reload)

```bash
cd /Users/jdmobileapp/Project/lms
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Option 2: Production Mode

```bash
cd /Users/jdmobileapp/Project/lms
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Option 3: Using Docker (Development)

```bash
cd /Users/jdmobileapp/Project/lms
docker-compose -f docker-compose.dev.yml up --build
```

### Option 4: Using Docker (Production)

```bash
cd /Users/jdmobileapp/Project/lms
docker-compose up -d --build
```

---

## Step 4: Verify Installation

### Health Check

```bash
curl http://localhost:8000/api/v1/health -H "X-API-Key: change-me-in-production"
```

### Expected Response

```json
{
  "status": "healthy",
  "components": {
    "llm": "available",
    "vector_store": "available",
    "embedding": "available"
  }
}
```

---

## API Documentation

Once the server is running, access the interactive API docs:

| Documentation  | URL                         |
| -------------- | --------------------------- |
| **Swagger UI** | http://localhost:8000/docs  |
| **ReDoc**      | http://localhost:8000/redoc |

---

## Common Commands

### Install Dependencies

```bash
source venv/bin/activate
pip install -r requirements.txt
```

### Run Tests

```bash
pytest tests/
```

### Run Tests with Coverage

```bash
pytest --cov=app --cov-report=html
```

---

## Troubleshooting

### Ollama Not Running

```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Start Ollama manually
ollama serve
```

### Port Already in Use

```bash
# Find process using port 8000
lsof -i :8000

# Kill the process
kill -9 <PID>
```

### Virtual Environment Issues

```bash
# Recreate virtual environment
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## Project Structure

```
lms/
├── app/
│   ├── main.py          # FastAPI application entry point
│   ├── api/             # API route handlers
│   ├── core/            # Configuration, security, logging
│   ├── schemas/         # Pydantic models
│   └── services/        # Business logic (RAG, LLM, processors)
├── data/
│   ├── chroma_db/       # Vector database storage
│   └── uploads/         # Uploaded documents
├── requirements.txt     # Python dependencies
├── .env                 # Environment variables
└── docker-compose.yml   # Docker configuration
```

---

## Quick Reference

| Action           | Command                                                                     |
| ---------------- | --------------------------------------------------------------------------- |
| Start server     | `uvicorn app.main:app --reload`                                             |
| Health check     | `curl localhost:8000/api/v1/health -H "X-API-Key: change-me-in-production"` |
| Upload document  | `POST /api/v1/documents/upload`                                             |
| Query documents  | `POST /api/v1/query`                                                        |
| Chat with memory | `POST /api/v1/chat`                                                         |

---

**Last Updated:** December 2024  
**Backend Version:** 1.0.0
