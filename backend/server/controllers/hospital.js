const Hospital = require("../models/hospital");
const { calculateDistance } = require("../utils/distance");
const { calculateHospitalScore } = require("../utils/hospitalScoring");

const recommendHospitals = async (req, res) => {

    try {

        const {
            latitude,
            longitude,
            required_specialties,
            urgency
        } = req.body;

        const hospitals = await Hospital.find({
            isOpen: true,
            isVerified: true
        });

        const rankedHospitals = hospitals.map(hospital => {

            const distance = calculateDistance(
                latitude,
                longitude,
                hospital.latitude,
                hospital.longitude
            );

            const score = calculateHospitalScore({
                hospital,
                requiredSpecialties: required_specialties,
                distance,
                urgency
            });

            return {
                ...hospital.toObject(),
                distance,
                score
            };

        });

        rankedHospitals.sort((a, b) => b.score - a.score);

        return res.status(200).json({
            success: true,
            hospitals: rankedHospitals.slice(0, 3)
        });

    } catch (error) {

        console.log(error);

        return res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

module.exports = {
    recommendHospitals
};