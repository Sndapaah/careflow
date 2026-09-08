const Hospital = require("../models/hospital");
const { calculateDistance } = require("../utils/distance");
const { calculateHospitalScore } = require("../utils/hospitalScoring");

const recommendHospitals = async (req, res) => {

    try {

        const {
            latitude,
            longitude,
            required_specialties,
            urgency,
            limit
        } = req.body;

        const hospitals = await Hospital.find({
            isOpen: true,
            // isVerified: true
        });

        const rankedHospitals = hospitals.map(hospital => {

            const distance = calculateDistance(
                latitude,
                longitude,
                hospital.location.coordinates[1],
                hospital.location.coordinates[0]
            );

            const score = calculateHospitalScore({
                hospital,
                requiredSpecialties: required_specialties,
                distance,
                urgency
            });

            return {
                ...hospital.toObject(),
                incomingPatients: hospital.incomingPatients || 0,
                emergencies: hospital.emergencies || 0,
                distance,
                score
            };

        });

        rankedHospitals.sort((a, b) => b.score - a.score);

        const resultLimit = urgency === "emergency" ? 1 : Math.min(Number(limit) || 3, 10);
        return res.status(200).json({
            success: true,
            hospitals: rankedHospitals.slice(0, resultLimit)
        });

    } catch (error) {

        console.log(error);

        return res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

const getHospitals = async (req, res) => {
    try {
        // Return the complete open facility set. The client calculates the
        // user's live distance and selects the nearest ten; limiting here
        // first could hide newly seeded facilities from that calculation.
        const hospitals = await Hospital.find({ isOpen: true })
        res.status(200).json({hospitals})
    } catch(err) {
        console.error(err)
    }
}

module.exports = {
    recommendHospitals,
    getHospitals,
};
