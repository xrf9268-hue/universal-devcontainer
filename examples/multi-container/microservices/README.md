# Microservices Architecture Example

Complete microservices system with API Gateway, multiple services, message queue, service discovery, and shared database.

## 🏗️ Architecture

```
                        ┌─────────────────┐
                        │   API Gateway   │
                        │    (Node.js)    │
                        │     :3000       │
                        └────────┬────────┘
                                 │
                 ┌───────────────┼───────────────┐
                 │               │               │
                 ▼               ▼               ▼
        ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
        │User Service │  │Product Svc  │  │Order Service│
        │  (Python)   │  │   (Go)      │  │  (Node.js)  │
        │   :3001     │  │   :3002     │  │   :3003     │
        └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
               │                │                │
               └────────────────┼────────────────┘
                                │
                 ┌──────────────┼──────────────┐
                 │              │              │
                 ▼              ▼              ▼
          ┌───────────┐  ┌───────────┐  ┌───────────┐
          │PostgreSQL │  │ RabbitMQ  │  │  Redis    │
          │  :5432    │  │:5672/15672│  │  :6379    │
          └───────────┘  └───────────┘  └───────────┘
                                │
                                ▼
                         ┌───────────┐
                         │  Consul   │
                         │   :8500   │
                         └───────────┘
```

## 🚀 Quick Start

```bash
cd examples/multi-container/microservices
code .
# Reopen in Container
```

## 📦 Services

### Development Container (app)
- **Languages**: Node.js 20, Python 3.12, Go 1.21
- **Purpose**: Run all microservices during development
- **Claude Code**: AI-powered coding assistant

### 1. API Gateway (:3000)
- **Tech**: Node.js + Express
- **Role**: Route requests to appropriate services
- **Features**:
  - Authentication
  - Rate limiting
  - Request logging
  - Load balancing

### 2. User Service (:3001)
- **Tech**: Python + FastAPI
- **Database**: PostgreSQL
- **Endpoints**:
  - `POST /users` - Create user
  - `GET /users/:id` - Get user
  - `PUT /users/:id` - Update user
  - `DELETE /users/:id` - Delete user

### 3. Product Service (:3002)
- **Tech**: Go + Gin
- **Database**: PostgreSQL
- **Endpoints**:
  - `POST /products` - Create product
  - `GET /products` - List products
  - `GET /products/:id` - Get product
  - `PUT /products/:id` - Update product

### 4. Order Service (:3003)
- **Tech**: Node.js + Express
- **Database**: PostgreSQL
- **Message Queue**: RabbitMQ
- **Endpoints**:
  - `POST /orders` - Create order
  - `GET /orders/:id` - Get order
  - `GET /orders/user/:userId` - User orders

### Supporting Services

**PostgreSQL** - Shared database for all services

**RabbitMQ** - Message broker for async communication
- Management UI: http://localhost:15672
- Credentials: guest/guest

**Redis** - Caching and session storage

**Consul** - Service discovery and health checks
- UI: http://localhost:8500

## 🛠️ Development

### Start All Services

Services start automatically. To start a specific service:

```bash
# Terminal 1: API Gateway
cd gateway
npm install
npm run dev

# Terminal 2: User Service
cd services/user
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 3001

# Terminal 3: Product Service
cd services/product
go run main.go

# Terminal 4: Order Service
cd services/order
npm install
npm run dev
```

### Service Communication

**Synchronous (HTTP)**:
```javascript
// Gateway calling User Service
const response = await axios.get('http://localhost:3001/users/123')
```

**Asynchronous (RabbitMQ)**:
```javascript
// Order Service publishing event
channel.publish('orders', 'order.created', Buffer.from(JSON.stringify(order)))

// User Service consuming event
channel.consume('user_notifications', (msg) => {
  const order = JSON.parse(msg.content.toString())
  // Send notification
})
```

### Database Access

Each service has its own schema:

```sql
-- User Service schema
CREATE SCHEMA users;
CREATE TABLE users.users (...);

-- Product Service schema
CREATE SCHEMA products;
CREATE TABLE products.products (...);

-- Order Service schema
CREATE SCHEMA orders;
CREATE TABLE orders.orders (...);
```

Access database:
```bash
pgcli postgresql://postgres:password@db:5432/microservices
```

## 🤖 Using Claude Code

### Build Microservices

**Create New Service**:
```
Claude, create a notification service:
1. Tech stack: Python + FastAPI
2. Listen to RabbitMQ for order events
3. Send emails using SMTP
4. Add health check endpoint
```

**Add Feature Across Services**:
```
Claude, add user loyalty points:
1. Update User Service to store points
2. Update Order Service to award points
3. Create RabbitMQ event when points change
4. Update API Gateway to expose points endpoint
```

**Add Service Discovery**:
```
Claude, integrate Consul:
1. Register each service on startup
2. Use Consul for service-to-service discovery
3. Add health checks
```

## 📝 Configuration

### Service Registry Pattern

```javascript
// Register service with Consul
const consul = require('consul')()

consul.agent.service.register({
  name: 'user-service',
  address: 'localhost',
  port: 3001,
  check: {
    http: 'http://localhost:3001/health',
    interval: '10s'
  }
})
```

### Environment Variables

Each service uses environment variables:

```bash
# User Service
DATABASE_URL=postgresql://postgres:password@db:5432/microservices
RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672/
REDIS_URL=redis://redis:6379
SERVICE_PORT=3001
```

## 🧪 Testing

### Integration Tests

```bash
# Test service-to-service communication
curl http://localhost:3000/api/users/1
curl http://localhost:3000/api/products
curl -X POST http://localhost:3000/api/orders -d '{"userId":1, "productId":1}'
```

### Message Queue Testing

```bash
# Access RabbitMQ Management UI
open http://localhost:15672

# Publish test message
curl -X POST http://localhost:3003/test/publish
```

### Service Health

```bash
# Check all services
curl http://localhost:3000/health  # Gateway
curl http://localhost:3001/health  # User Service
curl http://localhost:3002/health  # Product Service
curl http://localhost:3003/health  # Order Service
```

## 📊 Monitoring

### Consul UI
- Open: http://localhost:8500
- View: Service registry, health checks

### RabbitMQ Management
- Open: http://localhost:15672
- View: Queues, exchanges, message rates

### Database Monitoring
```sql
-- Active connections
SELECT * FROM pg_stat_activity;

-- Database size
SELECT pg_size_pretty(pg_database_size('microservices'));
```

## 🐛 Troubleshooting

### Service Not Responding
```bash
# Check if service is running
docker compose ps

# View service logs
docker compose logs user-service

# Restart service
docker compose restart user-service
```

### Message Queue Issues
```bash
# Check RabbitMQ status
docker compose logs rabbitmq

# Purge queue
# Use RabbitMQ Management UI
```

### Database Connection Pool
```bash
# Check active connections
psql $DATABASE_URL -c "SELECT count(*) FROM pg_stat_activity;"
```

## 🎯 Best Practices

1. **Service Independence**: Each service should be deployable independently
2. **Database Per Service**: Avoid shared tables across services
3. **Async Communication**: Use message queue for non-critical operations
4. **Circuit Breakers**: Implement fallbacks for service failures
5. **Centralized Logging**: Aggregate logs from all services
6. **API Versioning**: Use `/v1/`, `/v2/` prefixes
7. **Health Checks**: Every service must have a health endpoint

## 📚 Learn More

- [Microservices Pattern](https://microservices.io/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)
- [Consul Service Discovery](https://www.consul.io/docs/discovery)
- [API Gateway Pattern](https://microservices.io/patterns/apigateway.html)

## 🚀 Next Steps

1. Add authentication (JWT)
2. Implement circuit breakers (resilience4j)
3. Add distributed tracing (Jaeger/Zipkin)
4. Centralized logging (ELK stack)
5. API documentation (Swagger aggregation)
6. Load testing (k6/Artillery)

Happy microservices development! 🎯
