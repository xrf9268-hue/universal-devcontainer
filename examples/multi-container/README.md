# Multi-Container Examples

Examples demonstrating Docker Compose with Dev Containers for complex multi-service architectures.

## 📚 Available Examples

### [Full-Stack Application](fullstack/)
**Tech Stack**: React + FastAPI + PostgreSQL + Redis

Complete full-stack application with frontend, backend, database, and caching layer.

```
Frontend (React) ←→ Backend (FastAPI) ←→ PostgreSQL
                          ↓
                        Redis
```

**Services**:
- **Development Container** - Where you code (Node.js + Python)
- **PostgreSQL** - Primary database
- **Redis** - Caching and sessions
- **PgAdmin** - Database management UI (optional)

**Use Case**: Web applications, SaaS platforms, dashboards

[View Full-Stack README →](fullstack/README.md)

---

### [Microservices Architecture](microservices/)
**Tech Stack**: Node.js + Python + Go + PostgreSQL + RabbitMQ + Redis + Consul

Enterprise-grade microservices system with multiple services, message queue, and service discovery.

```
API Gateway (Node.js)
    ├─→ User Service (Python/FastAPI)
    ├─→ Product Service (Go/Gin)
    └─→ Order Service (Node.js/Express)
         ↓              ↓              ↓
    PostgreSQL    RabbitMQ        Redis
                      ↓
                  Consul
```

**Services**:
- **Development Container** - Multi-language support
- **API Gateway** - Request routing and auth
- **3 Microservices** - User, Product, Order
- **PostgreSQL** - Shared database
- **RabbitMQ** - Message broker
- **Redis** - Caching
- **Consul** - Service discovery

**Use Case**: Large-scale applications, distributed systems, event-driven architectures

[View Microservices README →](microservices/README.md)

---

## 🚀 Quick Start

### Full-Stack Example
```bash
cd examples/multi-container/fullstack
code .
# Reopen in Container
```

### Microservices Example
```bash
cd examples/multi-container/microservices
code .
# Reopen in Container
```

## 🏗️ How Multi-Container Works

### Docker Compose with Dev Containers

Dev Containers can use Docker Compose to orchestrate multiple services:

**Traditional Dev Container**:
- Single container for development
- External services via localhost

**Multi-Container Dev Container**:
- Development container + service containers
- All services in same network
- Services discover each other by name

### Configuration

**devcontainer.json**:
```json
{
  "name": "My Multi-Container App",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace"
}
```

**docker-compose.yml**:
```yaml
services:
  app:
    build: .devcontainer
    volumes:
      - ..:/workspace
    command: sleep infinity
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password

  redis:
    image: redis:7-alpine
```

## 📦 Benefits

### Development Experience
✅ **Realistic Environment** - Production-like setup locally
✅ **Service Isolation** - Each service in its own container
✅ **Easy Reset** - `docker compose down -v` to start fresh
✅ **Consistent** - Same environment for all developers

### Architecture Benefits
✅ **Service Communication** - Test inter-service calls
✅ **Database Migrations** - Run against real database
✅ **Message Queues** - Test async workflows
✅ **Caching** - Test cache strategies

### Claude Code Benefits
✅ **Full-Stack Features** - Build across frontend/backend
✅ **Service Generation** - Create new microservices
✅ **Database Schema** - Design and migrate schemas
✅ **API Integration** - Connect services together

## 🛠️ Common Operations

### Start All Services
```bash
# Services start automatically when container opens
docker compose ps
```

### View Logs
```bash
# All services
docker compose logs

# Specific service
docker compose logs db
docker compose logs redis

# Follow logs
docker compose logs -f app
```

### Restart Services
```bash
# Restart specific service
docker compose restart db

# Restart all services
docker compose restart
```

### Stop Services
```bash
# Stop all (keeps volumes)
docker compose stop

# Stop and remove (keeps volumes)
docker compose down

# Stop and remove everything including volumes
docker compose down -v
```

### Execute Commands in Service
```bash
# PostgreSQL
docker compose exec db psql -U postgres

# Redis
docker compose exec redis redis-cli

# Any service
docker compose exec app bash
```

## 🤖 Using Claude Code

### Full-Stack Features

**Create User Registration**:
```
Claude, create a complete user registration flow:
1. React form component with validation
2. FastAPI endpoint with password hashing
3. PostgreSQL user table migration
4. Email verification system
```

### Microservice Development

**Add New Service**:
```
Claude, create a notification microservice:
1. Tech: Python + FastAPI
2. Listen to RabbitMQ for events
3. Send emails via SMTP
4. Register with Consul
5. Add to docker-compose.yml
```

**Service Communication**:
```
Claude, make Order Service call Product Service:
1. Get product details when creating order
2. Handle service unavailable gracefully
3. Add circuit breaker pattern
```

## 📊 Comparison

| Aspect | Full-Stack | Microservices |
|--------|-----------|---------------|
| **Complexity** | Low | High |
| **Services** | 2-4 | 5+ |
| **Languages** | 1-2 | Multiple |
| **Best For** | Small to medium apps | Large enterprise apps |
| **Learning Curve** | Gentle | Steep |
| **Scalability** | Vertical | Horizontal |

## 🎯 When to Use

### Use Full-Stack When:
- Building MVPs or small applications
- Team is small (1-5 developers)
- Simple deployment requirements
- Rapid development needed
- Monolithic architecture is acceptable

### Use Microservices When:
- Large, complex applications
- Multiple teams working independently
- Different scalability needs per service
- Polyglot requirements (multiple languages)
- Need independent deployments

## 🐛 Troubleshooting

### Container Won't Start
```bash
# Check Docker Compose config
docker compose config

# View detailed logs
docker compose logs --tail=100

# Rebuild containers
docker compose build --no-cache
```

### Database Connection Issues
```bash
# Check database is running
docker compose ps db

# Test connection from app container
docker compose exec app psql postgresql://postgres:password@db:5432/myapp
```

### Port Conflicts
```bash
# Change ports in docker-compose.yml
ports:
  - "5433:5432"  # Use 5433 externally instead of 5432
```

### Out of Disk Space
```bash
# Clean up unused volumes
docker volume prune

# Remove all stopped containers
docker container prune

# Full cleanup (careful!)
docker system prune -a --volumes
```

## 📚 Learn More

- [Docker Compose in Dev Containers](https://containers.dev/guide/docker-compose)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Microservices Patterns](https://microservices.io/)
- [Full-Stack Development](https://fullstackopen.com/)

## 🎓 Next Steps

1. **Try Full-Stack Example** - Start simple
2. **Understand Docker Compose** - Learn service orchestration
3. **Explore Microservices** - Once comfortable with full-stack
4. **Add Monitoring** - Prometheus, Grafana
5. **Production Deploy** - Kubernetes, Docker Swarm

Happy multi-container development! 🚀
