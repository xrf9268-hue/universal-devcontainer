import express from 'express'
import cors from 'cors'
import helmet from 'helmet'

const app = express()
const PORT = process.env.PORT || 3000

// Middleware
app.use(helmet())
app.use(cors())
app.use(express.json())

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Express API + Claude Code',
    status: '✅ Running',
    features: [
      'TypeScript support',
      'Hot reload with tsx',
      'Security with Helmet',
      'CORS enabled',
      'Claude Code ready'
    ]
  })
})

app.get('/api/users', (req, res) => {
  res.json({
    users: [
      { id: 1, name: 'Alice' },
      { id: 2, name: 'Bob' }
    ]
  })
})

app.post('/api/users', (req, res) => {
  const { name } = req.body
  res.status(201).json({
    id: Date.now(),
    name
  })
})

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`)
  console.log('✅ Claude Code is ready to help!')
})
