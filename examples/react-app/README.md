# React + TypeScript Example

This example demonstrates using the Universal Dev Container with a React + TypeScript application built with Vite.

## 🚀 Quick Start

### Method 1: Clone and Open
```bash
git clone <your-repo>
cd examples/react-app
code .
# VS Code will prompt to "Reopen in Container"
```

### Method 2: Use as Template
```bash
# Copy this example to your project
cp -r examples/react-app/.devcontainer your-project/
cd your-project
code .
```

## 📦 What's Included

### Development Tools
- **Node.js 20** - LTS version
- **Vite** - Fast build tool and dev server
- **TypeScript** - Type safety
- **ESLint** - Code linting
- **Prettier** - Code formatting

### VS Code Extensions
- ESLint
- Prettier
- React snippets
- Tailwind CSS IntelliSense

### Claude Code Integration
- ✅ Host authentication method (uses your local Claude login)
- ✅ Bypass permissions (trusted repo mode)
- ✅ Plugins: commit-commands, pr-review-toolkit

#### 🚀 Advanced Plugins Option

Want more powerful Claude Code features? Use the **advanced plugins** configuration:

```bash
# Rename the advanced config to use it
mv .devcontainer/devcontainer.advanced-plugins.json .devcontainer/devcontainer.json
```

The advanced configuration includes:
- **frontend-dev-guidelines** - React/TypeScript best practices
- **code-review** - Automated PR review with confidence scoring
- **security-guidance** - Proactive security warnings
- **context-preservation** - Auto-save important context
- **commit-commands** - Git workflow automation

See [claude-code-plugins documentation](../../src/features/claude-code-plugins/README.md) for details.

## 🏗️ Project Structure

```
react-app/
├── .devcontainer/
│   └── devcontainer.json          # Dev Container configuration
├── src/
│   ├── App.tsx                    # Main React component
│   ├── main.tsx                   # Entry point
│   └── vite-env.d.ts              # Vite types
├── index.html                     # HTML template
├── package.json                   # Dependencies
├── tsconfig.json                  # TypeScript config
├── vite.config.ts                 # Vite config
└── README.md                      # This file
```

## 🛠️ Development

### Start Dev Server
```bash
npm run dev
```
Access at http://localhost:5173

### Build for Production
```bash
npm run build
```

### Lint Code
```bash
npm run lint
```

## 🤖 Using Claude Code

### Example Commands

**Create a new component:**
```
Claude, create a Button component with TypeScript props
```

**Add styling:**
```
Claude, add Tailwind CSS classes to make this button look modern
```

**Refactor code:**
```
Claude, extract this logic into a custom hook
```

**Fix issues:**
```
Claude, fix all ESLint warnings in this file
```

## 🎨 Customization

### Add Tailwind CSS
```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

Update `tailwind.config.js`:
```js
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

### Add React Router
```bash
npm install react-router-dom
npm install -D @types/react-router-dom
```

### Add State Management
```bash
# Zustand (recommended for simplicity)
npm install zustand

# Or Redux Toolkit
npm install @reduxjs/toolkit react-redux
```

## 📝 Configuration Details

### Dev Container Features

This example uses:
1. **Base Image**: `mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm`
2. **Node Feature**: Ensures Node.js 20 is installed
3. **Claude Code Feature**: Configured with host auth and bypass mode

### Port Forwarding

- **3000**: Alternative React dev server port
- **5173**: Vite default dev server port

Both ports are automatically forwarded and will show notifications when accessed.

### Post-Create Command

Automatically runs `npm install` after container creation to install dependencies.

## 🔒 Security Notes

This example uses `bypassPermissions: true` for Claude Code, which is appropriate for:
- ✅ Personal projects
- ✅ Trusted repositories
- ✅ Learning and experimentation

For enterprise or untrusted repos, consider:
- Set `bypassPermissions: false`
- Use the `safe` or `ultra-safe` permission preset
- Review Claude's actions before approval

## 📚 Learn More

- [React Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Vite Guide](https://vitejs.dev/guide/)
- [Universal Dev Container](../../README.md)
- [Claude Code Features](../../src/claude-code/README.md)

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Change port in package.json
"dev": "vite --port 5174"
```

### Module Not Found
```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### TypeScript Errors
```bash
# Restart TypeScript server in VS Code
Cmd/Ctrl + Shift + P → "TypeScript: Restart TS Server"
```

## 🎯 Next Steps

1. Initialize Git: `git init`
2. Create `.gitignore`: Include `node_modules/`, `dist/`, `.env`
3. Start coding with Claude Code assistance!
4. Deploy to Vercel, Netlify, or your preferred platform

Happy coding! 🚀
