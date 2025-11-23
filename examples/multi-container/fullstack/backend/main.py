from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI(title="Full-Stack Backend")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mock database
users_db = [
    {"id": 1, "name": "Alice"},
    {"id": 2, "name": "Bob"},
    {"id": 3, "name": "Charlie"}
]

@app.get("/")
def root():
    return {
        "message": "Full-Stack API Running",
        "database": os.getenv("DATABASE_URL", "not configured"),
        "redis": os.getenv("REDIS_URL", "not configured")
    }

@app.get("/api/users")
def get_users():
    return {"users": users_db}

@app.get("/health")
def health():
    return {"status": "healthy"}

# Example: Database connection (uncomment when ready)
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
"""

# Example: Redis connection (uncomment when ready)
"""
import redis

REDIS_URL = os.getenv("REDIS_URL")
redis_client = redis.from_url(REDIS_URL)
"""
