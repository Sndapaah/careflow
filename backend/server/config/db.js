const mongoose = require('mongoose')
require('dotenv').config()

const connectDB = async () => {
    const MONGO_URI = process.env.MONGO_URI
    try {
        const connectdb = await mongoose.connect(MONGO_URI)
        console.log('Database connected')
    } catch(err) {
        console.error(err.stack)
        console.error('DB Connection failed:: ' + err)
    }
}
module.exports = connectDB
