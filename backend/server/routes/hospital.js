const express = require("express");
const { recommendHospitals, getHospitals } = require("../controllers/hospital");

const router = express.Router();

router.get("/getHs", getHospitals);
router.post("/recommend", recommendHospitals);

module.exports = router;