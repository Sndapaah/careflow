const dns = require('dns');
dns.setServers(['1.1.1.1','8.8.8.8']);
const mongoose = require('mongoose')

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI)
        console.log('Database connected')
    } catch(err) {
        console.error(err?.message)
        console.error('DB Connection failed:: ' + err)
        throw err
    }
}
module.exports = connectDB
