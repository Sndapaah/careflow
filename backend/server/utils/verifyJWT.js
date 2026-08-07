const Users = require("../models/user.js")
const jwt = require('jsonwebtoken')

const verifyToken = (req, res, next) => {
    const header = req.headers.Authorization || req.headers.authorization

    if (!header?.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Invalid token format', ok: false })
    }

    const token = header.split(' ')[1]
    
    jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
        if (err) {
            console.log('The error:: ', err)
            return res.status(401).json({ expired: true, message: 'Token expired', ok: false })
        }
        req.user = await Users.findOne({ email: decoded.email })
        next()
    })
}

const verifyRole = roles => async (req, res, next) => {
    try {
        const header = req.headers.Authorization || req.headers.authorization

        if (!header?.startsWith('Bearer ')) {
        return res
            .status(401)
            .json({ message: 'Invalid token format', ok: false })
        }

        const token = header.split(' ')[1]

        jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
            if (err) {
                console.log(err)
                return res.status(401).json({ expired: true, message: 'Token expired', ok: false })
            }
            const user = await Users.findOne({ email: decoded.email })
            
            if (!user || !roles.includes(user.role)) {
                return res.status(403).json({ message: 'Access denied.' })
            }

            req.user = user
            next()
        })
    } catch (error) {
        res.status(401).json({ message: 'Please authenticate.' })
    }
}

module.exports = {
    verifyToken,
    verifyRole,
}