# Go Web Service Example

High-performance web service built with Go and the Gin framework, integrated with Claude Code.

## 🚀 Quick Start

```bash
cd examples/go-app
code .  # Reopen in container
go run main.go
```

Visit http://localhost:8080

## 📦 Stack

- **Go 1.21** - Fast, compiled language
- **Gin** - High-performance web framework
- **Native tools** - go fmt, go test, go build

## 🛠️ Commands

```bash
# Run development server
go run main.go

# Build executable
go build -o app

# Run tests
go test ./...

# Format code
go fmt ./...

# Install dependencies
go mod download
go mod tidy
```

## 🤖 Claude Code Examples

**Add a new endpoint:**
```
Claude, create a GET /api/products endpoint with pagination
```

**Add middleware:**
```
Claude, add logging middleware for all requests
```

**Add database:**
```
Claude, integrate GORM with PostgreSQL for database operations
```

**Add testing:**
```
Claude, create unit tests for all API endpoints
```

## 🎯 Project Structure

```
go-app/
├── .devcontainer/
│   └── devcontainer.json
├── main.go              # Main application
├── go.mod               # Dependencies
├── go.sum               # Dependency checksums
└── README.md
```

## 🎯 Next Steps

- Add GORM for database ORM
- Implement JWT authentication
- Add middleware (CORS, logging, recovery)
- Create structured logging (zap/logrus)
- Add testing with testify
- Deploy as Docker container

## 📚 Features

✅ **High performance** - Compiled, fast execution
✅ **Concurrency** - Goroutines and channels
✅ **Type safety** - Strong static typing
✅ **Simple deployment** - Single binary
✅ **Great tooling** - Built-in test, fmt, vet

## 🔧 Common Packages

```bash
# Web frameworks
go get github.com/gin-gonic/gin
go get github.com/gorilla/mux

# Database
go get gorm.io/gorm
go get gorm.io/driver/postgres

# Testing
go get github.com/stretchr/testify

# Configuration
go get github.com/spf13/viper
```

Happy coding! 🚀
