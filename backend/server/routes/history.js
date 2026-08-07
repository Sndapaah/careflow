const express = require("express");
const { getDiagnosisHistory } = require("../controllers/history");
const { verifyToken } = require("../utils/verifyJWT");

const router = express.Router();

router.get(
    "/history",
    verifyToken,
    getDiagnosisHistory
);

module.exports = router;