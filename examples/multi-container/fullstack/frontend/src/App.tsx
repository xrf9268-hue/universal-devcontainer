import { useState, useEffect } from 'react'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

function App() {
  const [message, setMessage] = useState('')
  const [users, setUsers] = useState([])

  useEffect(() => {
    // Fetch backend health
    axios.get(`${API_URL}/`)
      .then(res => setMessage(res.data.message))
      .catch(err => console.error(err))

    // Fetch users
    axios.get(`${API_URL}/api/users`)
      .then(res => setUsers(res.data.users))
      .catch(err => console.error(err))
  }, [])

  return (
    <div style={{ padding: '2rem', fontFamily: 'system-ui' }}>
      <h1>Full-Stack Multi-Container Example</h1>
      <p>React Frontend + FastAPI Backend + PostgreSQL + Redis</p>

      <div style={{ marginTop: '2rem' }}>
        <h2>Backend Status</h2>
        <p>Message from API: <strong>{message || 'Loading...'}</strong></p>
      </div>

      <div style={{ marginTop: '2rem' }}>
        <h2>Users from Database</h2>
        <ul>
          {users.map((user: any) => (
            <li key={user.id}>{user.name}</li>
          ))}
        </ul>
      </div>

      <div style={{ marginTop: '2rem', color: '#666' }}>
        <p>✅ Frontend: React + Vite</p>
        <p>✅ Backend: FastAPI (Python)</p>
        <p>✅ Database: PostgreSQL</p>
        <p>✅ Cache: Redis</p>
        <p>✅ Claude Code: Ready</p>
      </div>
    </div>
  )
}

export default App
