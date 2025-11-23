# Python FastAPI Example

Modern, fast (high-performance) web framework for building APIs with Python 3.12+ and Claude Code.

## 🚀 Quick Start

```bash
cd examples/python-fastapi
code .  # Reopen in container
uvicorn main:app --reload --host 0.0.0.0
```

Visit:
- API: http://localhost:8000
- Auto docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 📦 Stack

- **Python 3.12** - Latest Python
- **FastAPI** - Modern, fast web framework
- **Uvicorn** - ASGI server
- **Pydantic** - Data validation
- **Black** - Code formatter
- **Ruff** - Fast linter

## 🛠️ Commands

```bash
# Development
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4

# Code quality
black .
ruff check .
```

## 🤖 Claude Code Examples

**Add a new endpoint:**
```
Claude, create a POST /api/posts endpoint with title and content fields
```

**Add database:**
```
Claude, integrate SQLAlchemy with async PostgreSQL support
```

**Add authentication:**
```
Claude, implement JWT authentication with OAuth2
```

**Add testing:**
```
Claude, create pytest tests for all API endpoints
```

## 🎯 Next Steps

- Add SQLAlchemy/Tortoise ORM
- Implement JWT authentication
- Add Alembic migrations
- Set up pytest with coverage
- Add background tasks with Celery
- Deploy with Docker

## 📚 Features

✅ **Automatic API documentation** - Swagger UI at /docs
✅ **Type safety** - Pydantic models with validation
✅ **Async support** - Built-in async/await
✅ **High performance** - One of the fastest Python frameworks
✅ **Standards-based** - OpenAPI and JSON Schema

Happy coding! 🚀
