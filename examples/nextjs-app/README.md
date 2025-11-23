# Next.js 15 Example

This example demonstrates using the Universal Dev Container with Next.js 15 and TypeScript, featuring the new App Router and Server Components.

## 🚀 Quick Start

### Method 1: Clone and Open
```bash
git clone <your-repo>
cd examples/nextjs-app
code .
# VS Code will prompt to "Reopen in Container"
```

### Method 2: Use as Template
```bash
# Copy this example to your project
cp -r examples/nextjs-app/.devcontainer your-nextjs-project/
cd your-nextjs-project
code .
```

## 📦 What's Included

### Framework & Tools
- **Next.js 15** - Latest version with App Router
- **React 18** - With Server Components
- **TypeScript** - Full type safety
- **ESLint** - Next.js optimized linting
- **Turbopack** - Fast bundler (dev mode)

### VS Code Extensions
- ESLint
- Prettier
- Tailwind CSS IntelliSense
- Prisma (for database work)

### Claude Code Integration
- ✅ Host authentication method
- ✅ Bypass permissions (trusted repo)
- ✅ Community plugins (essential): commit-commands, code-review, security-guidance, context-preservation

## 🏗️ Project Structure

```
nextjs-app/
├── .devcontainer/
│   └── devcontainer.json          # Dev Container configuration
├── app/
│   ├── layout.tsx                 # Root layout
│   ├── page.tsx                   # Home page
│   └── globals.css                # Global styles
├── public/                        # Static assets
├── next.config.js                 # Next.js configuration
├── tsconfig.json                  # TypeScript config
├── package.json                   # Dependencies
└── README.md                      # This file
```

## 🛠️ Development

### Start Dev Server
```bash
npm run dev
```
Access at http://localhost:3000

### Build for Production
```bash
npm run build
npm run start
```

### Lint Code
```bash
npm run lint
```

## 🤖 Using Claude Code

### Example Commands

**Create a new page:**
```
Claude, create an about page at /about with server components
```

**Add API route:**
```
Claude, create an API route at /api/users that returns mock data
```

**Implement authentication:**
```
Claude, add NextAuth.js with GitHub provider
```

**Database integration:**
```
Claude, set up Prisma with PostgreSQL and create a User model
```

## 🎨 Customization

### Add Tailwind CSS
```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

Update `tailwind.config.ts`:
```ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
export default config
```

Add to `app/globals.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### Add Database with Prisma
```bash
npm install prisma @prisma/client
npx prisma init

# Edit prisma/schema.prisma
# Then:
npx prisma generate
npx prisma db push
```

### Add Authentication
```bash
npm install next-auth
```

Create `app/api/auth/[...nextauth]/route.ts`

### Add UI Components
```bash
# shadcn/ui (recommended)
npx shadcn-ui@latest init

# Or Radix UI
npm install @radix-ui/react-*
```

## 🚀 Next.js 15 Features

### Server Components (Default)
```tsx
// app/users/page.tsx
async function UsersPage() {
  const users = await fetchUsers() // Direct data fetching
  return <UserList users={users} />
}
```

### Server Actions
```tsx
// app/actions.ts
'use server'

export async function createUser(formData: FormData) {
  const name = formData.get('name')
  // Save to database
}
```

### Streaming & Suspense
```tsx
import { Suspense } from 'react'

export default function Page() {
  return (
    <Suspense fallback={<Loading />}>
      <UserList />
    </Suspense>
  )
}
```

### Metadata API
```tsx
export const metadata = {
  title: 'My App',
  description: 'Built with Next.js 15',
}
```

## 📝 Configuration Details

### Dev Container Features

1. **Base Image**: `mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm`
2. **Node.js 20**: LTS version for Next.js
3. **Claude Code Feature**: Host auth with bypass mode

### Port Forwarding

- **3000**: Next.js development server
- Auto-notification when server is ready

### Environment Variables

Create `.env.local` for local development:
```bash
DATABASE_URL="postgresql://user:pass@localhost:5432/db"
NEXTAUTH_SECRET="your-secret"
NEXTAUTH_URL="http://localhost:3000"
```

## 🔒 Security Notes

This example uses `bypassPermissions: true` for Claude Code.

**Appropriate for:**
- ✅ Personal projects
- ✅ Trusted repositories
- ✅ Rapid development

**For production/enterprise:**
- Set `bypassPermissions: false`
- Use environment variables for secrets
- Add `.env.local` to `.gitignore`

## 📚 Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [Next.js 15 Release Notes](https://nextjs.org/blog/next-15)
- [React Server Components](https://react.dev/reference/rsc/server-components)
- [Universal Dev Container](../../README.md)
- [Claude Code Features](../../src/claude-code/README.md)

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Use different port
npm run dev -- -p 3001
```

### Cache Issues
```bash
# Clear Next.js cache
rm -rf .next
npm run dev
```

### Type Errors
```bash
# Restart TypeScript server
# In VS Code: Cmd/Ctrl + Shift + P → "TypeScript: Restart TS Server"
```

### Turbopack Issues
```bash
# Disable Turbopack if needed
npm run dev -- --no-turbopack
```

## 🎯 Next Steps

1. Initialize Git: `git init`
2. Create `.gitignore`: Include `.next/`, `node_modules/`, `.env.local`
3. Add Tailwind CSS for styling
4. Set up database with Prisma
5. Deploy to Vercel with one click!

Happy coding with Next.js 15! 🚀
