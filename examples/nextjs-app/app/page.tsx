export default function Home() {
  return (
    <main style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1>Next.js 15 + TypeScript + Claude Code</h1>
      <p>Universal Dev Container Example</p>

      <div style={{ marginTop: '2rem', color: '#666' }}>
        <p>✅ Dev Container is running</p>
        <p>✅ Next.js 15 with App Router</p>
        <p>✅ Server Components enabled</p>
        <p>✅ Claude Code ready</p>
      </div>

      <div style={{ marginTop: '2rem', fontSize: '0.9rem' }}>
        <p>Try asking Claude to:</p>
        <ul>
          <li>Create a new page with Server Components</li>
          <li>Add an API route</li>
          <li>Set up Prisma for database access</li>
          <li>Implement authentication with NextAuth</li>
          <li>Add Tailwind CSS styling</li>
        </ul>
      </div>
    </main>
  )
}
