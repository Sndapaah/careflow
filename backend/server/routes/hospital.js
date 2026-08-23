const express = require("express");
const { recommendHospitals } = require("../controllers/hospital");
const { verifyToken } = require('../utils/verifyJWT');
const { startArrival, heartbeatArrival, cancelArrival } = require('../controllers/facility_arrival');

const router = express.Router();

router.post("/recommend", recommendHospitals);
router.post('/:facilityId/arrivals', verifyToken, startArrival);
router.patch('/:facilityId/arrivals/:arrivalId', verifyToken, heartbeatArrival);
router.delete('/:facilityId/arrivals/:arrivalId', verifyToken, cancelArrival);

module.exports = router;
