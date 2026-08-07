const mongoose = require('mongoose')

const userSchema = new mongoose.Schema({
    fullname: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    contact: {
        type: String,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    gender: {
        type: String,
        enum: ['male', 'female'],
        default: null
    },
    birthdate: {
        type: String,
        default: null
    },
    existingHealthConds: [],
    allergies: [],
    emergencyContact: {
        fullname: String,
        relType: String,
        contact: String,
    },
    bloodType: String,
    otp: String,
    otpExpires: Date,
    expoPushToken: String,
    isAuthenticated: {
        type: Boolean,
        default: false,
    },
    role: {
        type: String,
        enum: ['user', 'admin'],
        default: 'user'
    }
}, { timestamps: true })

const Users = mongoose.model('User', userSchema)
module.exports = Users


