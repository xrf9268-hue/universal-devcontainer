# Framework Examples

Complete working examples demonstrating how to use the Universal Dev Container with popular web frameworks and languages.

## 📚 Available Examples

### Frontend Frameworks

#### 🔷 [React + TypeScript](react-app/)
Modern React application with Vite, TypeScript, and hot module replacement.

**Stack**: React 18, TypeScript, Vite, ESLint, Prettier
**Port**: 5173
**Use Case**: SPAs, interactive UIs, component-based apps

```bash
cd examples/react-app && code .
```

#### 🟢 [Next.js 15](nextjs-app/)
Full-stack React framework with App Router, Server Components, and TypeScript.

**Stack**: Next.js 15, React 18, TypeScript, Turbopack
**Port**: 3000
**Use Case**: Full-stack apps, SSR, SSG, API routes

```bash
cd examples/nextjs-app && code .
```

### Backend Frameworks

#### 🟡 [Node.js + Express](nodejs-express/)
Fast, minimalist web framework for Node.js with TypeScript support.

**Stack**: Express 4, TypeScript, tsx, Helmet, CORS
**Port**: 3000
**Use Case**: REST APIs, microservices, middleware-based apps

```bash
cd examples/nodejs-express && code .
```

#### ⚡ [Python + FastAPI](python-fastapi/)
Modern, high-performance Python framework with automatic API documentation.

**Stack**: FastAPI, Python 3.12, Pydantic, Uvicorn
**Port**: 8000
**Use Case**: REST APIs, async operations, data validation

```bash
cd examples/python-fastapi && code .
```

#### 🐍 [Python + Django](python-django/)
Batteries-included web framework for rapid development with Django ORM.

**Stack**: Django 5.0, Python 3.12, Django REST Framework
**Port**: 8000
**Use Case**: Full-stack apps, admin panels, ORM-based apps

```bash
cd examples/python-django && code .
```

#### 🔵 [Go + Gin](go-app/)
High-performance web service built with Go and the Gin framework.

**Stack**: Go 1.21, Gin, Native concurrency
**Port**: 8080
**Use Case**: Microservices, high-performance APIs, concurrent systems

```bash
cd examples/go-app && code .
```

---

## 🚀 Quick Start

### Method 1: Clone and Use
```bash
# Clone the repository
git clone <your-repo>

# Navigate to an example
cd examples/react-app

# Open in VS Code
code .

# VS Code will prompt: "Reopen in Container"
# Click "Reopen in Container"

# Wait for container to build (first time only)
# Start coding with Claude Code!
```

### Method 2: Copy to Your Project
```bash
# Copy dev container config to your existing project
cp -r examples/react-app/.devcontainer your-project/

# Open your project in VS Code
cd your-project
code .

# Reopen in container
```

### Method 3: Use as Template
Each example can be used as a project template:
```bash
# Create new project from example
cp -r examples/nextjs-app my-new-project
cd my-new-project
rm -rf .git  # Remove example git history
git init     # Start fresh
code .
```

---

## 📋 What's Included in Each Example

### Common Features (All Examples)
✅ **Claude Code Integration** - AI-powered coding assistant
✅ **VS Code Extensions** - Language-specific extensions pre-installed
✅ **Dev Container Config** - Complete `.devcontainer/devcontainer.json`
✅ **Port Forwarding** - Automatic port mapping
✅ **README Guide** - Detailed documentation for each example
✅ **Starter Code** - Working application to get started

### Framework-Specific
Each example includes:
- Language runtime (Node.js, Python, Go)
- Framework setup (React, Next.js, Express, etc.)
- Package manager config (package.json, requirements.txt, go.mod)
- Linting & formatting tools
- TypeScript configuration (where applicable)
- Example API endpoints or components
- .gitignore for the stack

---

## 🎯 Choosing the Right Example

### For Frontend Development
| Need | Example | Best For |
|------|---------|----------|
| SPA with components | React | Interactive UIs, dashboards |
| Full-stack with SSR | Next.js | SEO, performance, full-stack |

### For Backend APIs
| Need | Example | Best For |
|------|---------|----------|
| JavaScript/TypeScript | Express | Node.js ecosystem, npm packages |
| Fast Python API | FastAPI | Async, auto-docs, data validation |
| Full Python framework | Django | ORM, admin, batteries-included |
| High performance | Go | Speed, concurrency, microservices |

---

## 🤖 Using Claude Code in Examples

All examples come pre-configured with Claude Code. Here are common commands you can try:

### Creating Components/Endpoints
```
Claude, create a new User component with props for name and email
Claude, add a POST /api/login endpoint with validation
```

### Adding Features
```
Claude, add Tailwind CSS to this project
Claude, integrate Prisma with PostgreSQL
Claude, set up JWT authentication
```

### Code Improvements
```
Claude, refactor this code to use async/await
Claude, add error handling to all API routes
Claude, fix all ESLint warnings
```

### Testing & Documentation
```
Claude, create unit tests for this component
Claude, add JSDoc comments to all functions
Claude, generate API documentation
```

---

## 📝 Customization

### Modify Dev Container
Each example's `.devcontainer/devcontainer.json` can be customized:

```json
{
  "features": {
    // Add more features
    "ghcr.io/xrf9268-hue/features/toolset-database:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        // Add more extensions
        "eamodio.gitlens"
      ]
    }
  }
}
```

### Add Database
Most examples can easily add a database:

**PostgreSQL**:
```json
{
  "features": {
    "ghcr.io/devcontainers/features/postgres:1": {}
  }
}
```

**MongoDB**:
```json
{
  "features": {
    "ghcr.io/devcontainers/features/mongodb:1": {}
  }
}
```

### Change Claude Code Settings
Adjust permissions in `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/claude-code:1": {
      "loginMethod": "api-key",      // Use API key instead
      "bypassPermissions": false      // Require approval
    }
  }
}
```

---

## 🔧 Troubleshooting

### Container Build Fails
```bash
# Rebuild without cache
Cmd/Ctrl + Shift + P → "Dev Containers: Rebuild Container"
```

### Port Already in Use
```bash
# Change port in example's config
# React: vite.config.ts
# Next.js: package.json scripts
# Express/FastAPI/Django: main file
```

### Slow First Build
First-time builds download base images and install dependencies. Subsequent builds are much faster thanks to caching.

### Claude Code Not Working
```bash
# Check import script ran
bash ~/.claude/import-host-settings.sh

# Or manually login
claude login
```

---

## 🎓 Learning Path

**Beginner Path**:
1. Start with **React** or **Next.js** (frontend)
2. Learn **Express** or **FastAPI** (backend)
3. Combine for full-stack app

**API-First Path**:
1. Start with **FastAPI** (easiest to learn)
2. Try **Express** (JavaScript ecosystem)
3. Explore **Go** (performance)

**Enterprise Path**:
1. **Django** for full-stack Python
2. **Next.js** for modern React
3. **Go** for microservices

---

## 📚 Additional Resources

### Universal Dev Container
- [Main README](../README.md)
- [Implementation Plan](../IMPLEMENTATION_PLAN.md)
- [Claude Code Feature](../src/claude-code/README.md)
- [Firewall Feature](../src/firewall/README.md)

### Framework Documentation
- [React](https://react.dev)
- [Next.js](https://nextjs.org)
- [Express](https://expressjs.com)
- [FastAPI](https://fastapi.tiangolo.com)
- [Django](https://www.djangoproject.com)
- [Go](https://go.dev)

### Dev Containers
- [Dev Containers Spec](https://containers.dev)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)

---

## 🤝 Contributing

Have an example you'd like to add? Contributions welcome!

**Good examples to add**:
- Vue 3 + Nuxt
- Rust + Actix
- Ruby on Rails
- PHP + Laravel
- .NET + ASP.NET Core

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

---

## 📊 Comparison Matrix

| Example | Language | Type | Speed | Learning Curve | Use Case |
|---------|----------|------|-------|----------------|----------|
| React | JavaScript/TS | Frontend | Fast | Medium | SPAs, UIs |
| Next.js | JavaScript/TS | Full-stack | Fast | Medium | SSR, Full-stack |
| Express | JavaScript/TS | Backend | Fast | Easy | APIs, Middleware |
| FastAPI | Python | Backend | Very Fast | Easy | APIs, Async |
| Django | Python | Full-stack | Medium | Medium | Full-stack, Admin |
| Go | Go | Backend | Very Fast | Medium | Performance, Scale |

---

**Need help?** Ask Claude Code! It's already configured in each example and ready to assist. 🚀

Happy coding!
