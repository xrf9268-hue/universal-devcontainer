from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(
    title="FastAPI + Claude Code",
    description="Universal Dev Container Example",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Models
class User(BaseModel):
    id: int | None = None
    name: str
    email: str

# In-memory database
users_db = [
    User(id=1, name="Alice", email="alice@example.com"),
    User(id=2, name="Bob", email="bob@example.com"),
]

# Routes
@app.get("/")
def root():
    return {
        "message": "FastAPI + Claude Code",
        "status": "✅ Running",
        "docs": "/docs",
        "features": [
            "Python 3.12",
            "FastAPI with auto-documentation",
            "Pydantic data validation",
            "CORS enabled",
            "Claude Code ready"
        ]
    }

@app.get("/api/users", response_model=list[User])
def get_users():
    return users_db

@app.get("/api/users/{user_id}", response_model=User)
def get_user(user_id: int):
    for user in users_db:
        if user.id == user_id:
            return user
    return {"error": "User not found"}

@app.post("/api/users", response_model=User, status_code=201)
def create_user(user: User):
    user.id = len(users_db) + 1
    users_db.append(user)
    return user

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
