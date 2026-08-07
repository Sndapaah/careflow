const express = require("express");
const { diagnosePatient } = require("../controllers/diagnosis");
const { verifyToken } = require("../utils/verifyJWT");

const router = express.Router();


router.post("/diagnose", verifyToken, diagnosePatient)

module.exports = router;