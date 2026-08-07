const { Router } = require('express')
const {
    register,
    addPersonalization,
    verifyOTPCode_completeSignup,
    reverify_user,
    login,
    resetUserPassword,
    resetPasswordAfterVerification
} = require('../controllers/auth')

const router = Router()

router.post('/register', register)
router.post('/verifyOTP/:id', verifyOTPCode_completeSignup)
router.post('/resend_otp_code/:email', reverify_user)
router.post('/login', login)
router.post('/resetPassword', resetUserPassword); //new with otp verification
router.post('/reset-user-password', resetPasswordAfterVerification); //save password after verification
router.post('/addPersonalization/:id', addPersonalization)

module.exports = router