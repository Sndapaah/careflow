const express = require('express')
const dotenv = require('dotenv')
const connectDB = require('./config/db')
const cors = require('cors')
const helmet = require('helmet')
const rateLimit = require('express-rate-limit')
const authRoutes = require('./routes/auth')
const hospitalRoutes = require('./routes/hospital')
const diagnosisRoutes = require('./routes/diagnosis')
const historyRoutes = require('./routes/history')

dotenv.config()

const app = express()

app.use(express.json())
app.use(cors({
    origin: '*',
    credentials: true
}))
app.use(helmet())

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 500,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many requests, slow down a bit.' }
})

app.use(limiter);

// routes here
app.use('/api/auth', authRoutes)
app.use('/api/hospitals', hospitalRoutes)
app.use('/api/diagnosis', diagnosisRoutes)
app.use('/api/history', historyRoutes)


connectDB()
const PORT = process.env.PORT
app.listen(PORT, () => {
    console.log(`Server is running on PORT ${PORT}`)
})