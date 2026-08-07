const nodemailer = require('nodemailer')
const dotnev = require('dotenv').config()

// generate 6-digit OTP
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.APP_EMAIL,
    pass: process.env.APP_PASS,
  },
});

// send OTP email
const sendOTP = async (email, otp) => {
  try {
    const mailOptions = {
      from: `"Careflow Ai" <${process.env.APP_EMAIL}>`,
      to: email,
      subject: "Your Verification Code",
      html: `
        <div style="background:#f4f6f8;padding:40px 0;font-family:Arial,Helvetica,sans-serif">
          <div style="max-width:500px;margin:auto;background:#ffffff;border-radius:10px;overflow:hidden;box-shadow:0 4px 12px rgba(0,0,0,0.08)">
            
            <div style="padding:20px;text-align:center;color:white">
              <h2 style="margin:0;font-weight:600;color: #1d9eed;">Email Verification</h2>
            </div>

            <div style="padding:30px;text-align:center">
              <p style="font-size:16px;color:#555;margin-bottom:10px">
                Use the code below to verify your email
              </p>

              <div style="
                font-size:32px;
                letter-spacing:8px;
                font-weight:bold;
                color:#1d9eed;
                background:#f1f5ff;
                padding:15px 20px;
                border-radius:8px;
                display:inline-block;
                margin:20px 0;
              ">
                ${otp}
              </div>

              <p style="font-size:14px;color:#777;margin-top:10px">
                This code will expire in <b>15 minutes</b>.
              </p>

              <p style="font-size:13px;color:#999;margin-top:30px">
                If you didn’t request this code, you can safely ignore this email.
              </p>
            </div>

            <div style="background:#f4f6f8;padding:15px;text-align:center;font-size:12px;color:#888">
              © ${new Date().getFullYear()} Careflow Ai - Ghana
            </div>

          </div>
        </div>
      `,
    };
    console.log(email)
    await transporter.sendMail(mailOptions);

    return true;
  } catch (error) {
    console.error("OTP email error:", error);
    return false;
  }
};


module.exports = {
  generateOTP,
  sendOTP
}