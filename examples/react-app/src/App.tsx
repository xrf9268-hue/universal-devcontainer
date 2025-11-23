import { useState } from 'react'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1>React + TypeScript + Claude Code</h1>
      <p>Universal Dev Container Example</p>

      <div style={{ marginTop: '2rem' }}>
        <button
          onClick={() => setCount((count) => count + 1)}
          style={{
            padding: '0.5rem 1rem',
            fontSize: '1rem',
            cursor: 'pointer'
          }}
        >
          Count is {count}
        </button>
      </div>

      <div style={{ marginTop: '2rem', color: '#666' }}>
        <p>✅ Dev Container is running</p>
        <p>✅ React with TypeScript</p>
        <p>✅ Vite HMR enabled</p>
        <p>✅ Claude Code ready</p>
      </div>

      <div style={{ marginTop: '2rem', fontSize: '0.9rem' }}>
        <p>Try asking Claude to:</p>
        <ul>
          <li>Add styling with Tailwind CSS</li>
          <li>Create a new component</li>
          <li>Add React Router</li>
          <li>Implement state management</li>
        </ul>
      </div>
    </div>
  )
}

export default App
