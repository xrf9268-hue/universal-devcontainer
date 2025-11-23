# Full-Stack Multi-Container Example

Complete full-stack application with React frontend, FastAPI backend, PostgreSQL database, and Redis cache - all running in separate containers.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│  Development Container (app)                        │
│  ├─ Frontend: React + Vite (port 3000)             │
│  ├─ Backend: FastAPI (port 3001)                   │
│  └─ Claude Code AI Assistant                        │
└─────────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
  ┌──────────┐   ┌──────────┐   ┌──────────┐
  │PostgreSQL│   │  Redis   │   │ PgAdmin  │
  │  :5432   │   │  :6379   │   │  :5050   │
  └──────────┘   └──────────┘   └──────────┘
```

## 🚀 Quick Start

```bash
cd examples/multi-container/fullstack
code .
# VS Code will prompt to "Reopen in Container"
```

**First time setup**:
1. Container builds all services
2. Dependencies auto-install
3. Database initializes
4. Ready to code!

## 📦 Services

### 1. Development Container (app)
- **Node.js 20** - Frontend runtime
- **Python 3.12** - Backend runtime
- **Claude Code** - AI assistant
- **Database tools** - pgcli, redis-cli

### 2. PostgreSQL (db)
- **Version**: PostgreSQL 15
- **Port**: 5432
- **User**: postgres
- **Password**: password
- **Database**: myapp
- **Persistent**: Yes (docker volume)

### 3. Redis (redis)
- **Version**: Redis 7
- **Port**: 6379
- **Persistent**: Yes (docker volume)
- **Use**: Caching, sessions

### 4. PgAdmin (pgadmin) - Optional
- **Port**: 5050
- **Email**: admin@example.com
- **Password**: admin
- **Access**: http://localhost:5050

## 🛠️ Development Workflow

### Start All Services
```bash
# Services start automatically when container opens
# Check status:
docker compose ps
```

### Frontend Development
```bash
# Terminal 1: Start frontend
cd frontend
npm install
npm run dev
# Access: http://localhost:3000
```

### Backend Development
```bash
# Terminal 2: Start backend
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 3001
# Access: http://localhost:3001/docs
```

### Database Access

**Method 1: pgcli (in container)**
```bash
pgcli postgresql://postgres:password@db:5432/myapp
```

**Method 2: VS Code SQLTools**
- Already configured in devcontainer.json
- Click SQL icon in sidebar
- Connect to "PostgreSQL" connection

**Method 3: PgAdmin Web UI**
- Open http://localhost:5050
- Login with admin@example.com / admin
- Add server:
  - Host: db
  - Port: 5432
  - Username: postgres
  - Password: password

### Redis Access
```bash
# Connect to Redis
redis-cli -h redis

# Test commands
PING
SET mykey "Hello"
GET mykey
```

## 📁 Project Structure

```
fullstack/
├── .devcontainer/
│   ├── devcontainer.json       # Dev Container config
│   └── Dockerfile              # Custom image
├── docker-compose.yml          # Multi-container setup
├── frontend/                   # React app
│   ├── package.json
│   ├── vite.config.ts
│   └── src/
├── backend/                    # FastAPI app
│   ├── main.py
│   ├── requirements.txt
│   └── models/
└── README.md
```

## 🤖 Using Claude Code

### Create Full-Stack Features

**Frontend + Backend**:
```
Claude, create a user registration feature:
1. React form component in frontend/
2. FastAPI endpoint in backend/
3. PostgreSQL user table
4. Form validation on both sides
```

**Database Operations**:
```
Claude, create a blog post CRUD:
- Database schema with Prisma/SQLAlchemy
- REST API endpoints
- React components for list/create/edit
```

**Add Redis Caching**:
```
Claude, add Redis caching to the user profile endpoint
```

## 🔧 Configuration

### Environment Variables

Create `.env` file:
```bash
# Database
DATABASE_URL=postgresql://postgres:password@db:5432/myapp

# Redis
REDIS_URL=redis://redis:6379

# API
API_PORT=3001
FRONTEND_PORT=3000

# Development
NODE_ENV=development
DEBUG=true
```

### Database Migrations

**Using Prisma** (TypeScript/Node):
```bash
cd backend
npx prisma init
npx prisma migrate dev --name init
npx prisma generate
```

**Using Alembic** (Python):
```bash
cd backend
alembic init migrations
alembic revision --autogenerate -m "initial"
alembic upgrade head
```

## 🧪 Testing

### Run Backend Tests
```bash
cd backend
pytest
```

### Run Frontend Tests
```bash
cd frontend
npm test
```

### Integration Tests
```bash
# Test database connection
psql $DATABASE_URL -c "SELECT 1;"

# Test Redis connection
redis-cli -h redis PING

# Test API
curl http://localhost:3001/health
```

## 🐛 Troubleshooting

### Services Not Starting
```bash
# Check service logs
docker compose logs db
docker compose logs redis

# Restart specific service
docker compose restart db
```

### Database Connection Failed
```bash
# Check database is ready
docker compose ps db

# Check connection
psql postgresql://postgres:password@db:5432/myapp -c "SELECT version();"
```

### Port Conflicts
```bash
# Change ports in docker-compose.yml
ports:
  - "5433:5432"  # Use 5433 instead of 5432
```

### Reset Everything
```bash
# Remove all data and start fresh
docker compose down -v
# Reopen container in VS Code
```

## 📚 Learn More

- [Docker Compose in Dev Containers](https://containers.dev/guide/docker-compose)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Vite Documentation](https://vitejs.dev/)

## 🎯 Next Steps

1. **Initialize Database**:
   - Run migrations
   - Seed sample data

2. **Build Features**:
   - User authentication (JWT)
   - Real-time updates (WebSockets)
   - File uploads (S3/local)

3. **Add Services**:
   - Elasticsearch for search
   - RabbitMQ for queues
   - Nginx for reverse proxy

4. **Production Ready**:
   - Add Docker production images
   - Environment-specific configs
   - Health checks
   - Monitoring

Happy full-stack development! 🚀
