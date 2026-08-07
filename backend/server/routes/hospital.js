const express = require("express");
const { recommendHospitals } = require("../controllers/hospital");

const router = express.Router();

router.post("/recommend", recommendHospitals);

module.exports = router;