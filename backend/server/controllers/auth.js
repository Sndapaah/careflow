const Users = require("../models/user")
const bcrypt = require('bcrypt')
const { generateOTP, sendOTP } = require('../utils/sendOTP')
const jwt = require('jsonwebtoken')

const register = async (req, res) => {
  const {
    fullname,
    email,
    contact,
    password,
  } = req.body
  try {
    if(!fullname) return res.status(404).json({ message: 'Your fullname is required to complete registration' })
    if(!email) return res.status(404).json({ message: 'Your email is required to complete registration' })
    if(!contact) return res.status(404).json({ message: 'Your contact is required to complete registration' })
    if(!password) return res.status(404).json({ message: 'Your password is required to complete registration' })
    
    // const alreadyExisting = await Users.findOne({ email, contact }) 
    // if(alreadyExisting) return res.status(400).json({ message: 'Account already exist' })
    const alreadyExisting = await Users.findOne({ email })
    if(alreadyExisting) return res.status(400).json({ message: 'Account already exist' })

    const saltRounds = 10
    const salt = await bcrypt.genSalt(saltRounds)
    const hashedPass = await bcrypt.hash(password, salt)
    const newUser = new Users({
      fullname,
      email,
      contact,
      password: hashedPass
    })
    await newUser.save()
    // send OTP
    const otp = generateOTP()
    const sent = sendOTP(email, otp)
    if(!sent) return res.status(500).json({ message: 'Failed to send OTP' })
    newUser.otp = otp
    newUser.otpExpires = Date.now() + 900000
    newUser.save()
    
    res.status(201).json({ 
      id: newUser._id,
      email: newUser.email,
      message: 'OTP sent to your email', 
    })
  } catch(err) {
    console.error('Registration Error', err)
    res.status(500).json({ message: 'Server Error'})
  }
}

const verifyOTPCode_completeSignup = async (req, res) => {
  const { id } = req.params
  const { otp } = req.body

  try {
    const user = await Users.findById(id)
    if(!user) return res.status(404).json({ message: 'User not found' })

    const userOTP = user.otp
    const isOTPValid = user.otpExpires > new Date()
    if(userOTP === otp) {
      if(isOTPValid) {
        user.isAuthenticated = true
        user.otp = undefined
        user.otpExpires = undefined
        await user.save()
        
        return res.status(200).json({
          message: 'Sign up complete, please login'
        })
      } else {
        return res.status(400).json({ 
          message: 'OTP expired'
        })
      }
    } else {
      return res.status(400).json({ message: 'Invalid OTP' })
    }
  } catch(err) {
    console.error(err)
    res.status(500).json({ message: 'An error occured verifying OTP.' })
  }
}

const reverify_user = async (req, res) => {
  const { email } = req.params
  try {
    const user = await Users.findOne({ email }).collation({ locale: 'en', strength: 2 });
    if(!user) return res.status(404).json({ message: 'No such account, please register' })
      
    const otp = generateOTP()
    const sent = sendOTP(email, otp)
    if(!sent) return res.status(500).json({ message: 'Failed to send OTP' })

    user.otp = otp
    user.otpExpires = Date.now() + 900000
    user.save()
    
    res.status(200).json({ 
      id: user._id,
      email: user.email,
      message: 'OTP sent to your email', 
    })
  } catch(err) {
    console.error(err)
    res.status(500).json({ message: 'Something went wrong'})
  }
}

const addPersonalization = async (req, res) => {
  const { id } = req.params
  const {
    gender,
    birthdate,
    emergencyContact,
    existingHealthConds,
    allergies,
    bloodType,
  } = req.body
  try{
    if(!gender) return res.status(404).json({ message: 'Your gender is required'})
    if(!birthdate) return res.status(404).json({ message: 'Your birthdate is required'})
    if(!emergencyContact) return res.status(404).json({ message: 'An emergency contact is required'})
    
    const user = await Users.findById(id)
    if(!user) return res.status(404).json({ message: 'User not found. Cannot complete personalization' })
    
    user.gender = gender
    user.birthdate = birthdate
    user.emergencyContact = emergencyContact
    if(existingHealthConds) user.existingHealthConds = existingHealthConds
    if(allergies) user.allergies = allergies
    if(bloodType) user.bloodType = bloodType

    await user.save()

    res.status(200).json({ message: 'Personalization complete'})
  } catch(err) {
    console.error('PERSONALIZATION ERROR', err)
    res.status(500).json({ message: 'Server error '})
  }
}

const login = async (req, res) => {
  const { email, password } = req.body
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password required!' })
  }
  const foundUser = await Users.findOne({ email }).exec()
  if (!foundUser) {
    return res
      .status(401)
      .json({ message: 'Account not found, Please register.', ok: false })
  }

  try {
    const isValidated = await bcrypt.compare(password, foundUser.password)
    if (!isValidated) {
      return res
      .status(401)
      .json({ message: 'Incorrect password entered!' })
    }

    if(!foundUser.isAuthenticated) return res.status(403).json({ unVerified: true, message: 'Please verify your account to login' })

    const accessToken = jwt.sign(
      {
        _id: foundUser._id,
        email,
        fullname: foundUser.fullname,
        contact: foundUser.contact,
        role: foundUser.role
      },
      process.env.JWT_SECRET,
      { expiresIn: '180d' }
    )

    // //Exclude the refreshToken fields and password field
    const { 
      password: pass, 
      ...rest 
    } = foundUser._doc
    return res.status(200).json({
      message: `User ${foundUser.fullname} successfully logged in!`,
      user: { ...rest, accessToken },
    })
  } catch (error) {
    console.log(error)
    return res
      .status(401)
      .json({ message: 'Error while logging in', ok: false })
  }
}

const resetUserPassword = async (req, res) => {
  const { email } = req.body
  try {
    const user = await Users.findOne({ email })
    if(!user) return res.status(404).json({ message: 'User not found or the email is incorrect'})

    const otp = generateOTP()
    const sent = sendOTP(email, otp)
    if(!sent) return res.status(500).json({ message: 'Failed to send OTP' })

    user.otp = otp
    user.otpExpires = Date.now() + 900000
    user.save()
    
    res.status(200).json({ 
      id: user._id,
      email: user.email,
      message: 'OTP sent to your email', 
    })
    
  } catch(err) {
    console.error(err)
    res.status(500).json({ message: 'Server Error'})
  }
}

const resetPasswordAfterVerification = async (req, res) => {
  const { password, email } = req.body
  try {
    const user = await Users.findOne({ email })
    if(!user) return res.status(404).json({ message: 'User does not exist'})

    const samePasswordEntered = await bcrypt.compare(password, user.password)
    if(samePasswordEntered) return res.status(409).json({ message: 'You recently used this password, kindly enter a different one' })

    const saltRounds = 10 
    const salt = await bcrypt.genSalt(saltRounds)
    const hashedPassword = await bcrypt.hash(password, salt)

    user.password = hashedPassword
    await user.save()

    res.status(200).json({ message: 'Password reset successful, please login'})
  } catch(err) {
    console.error(err)
    res.status(500).json({ message: 'Server error '})
  }
}

module.exports = {
  register,
  verifyOTPCode_completeSignup,
  reverify_user,
  addPersonalization,
  login,
  resetUserPassword,
  resetPasswordAfterVerification
}