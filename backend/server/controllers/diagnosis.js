const axios = require("axios");
const Hospital = require("../models/hospital");
const Diagnosis = require("../models/diagnosis");

const { calculateDistance } = require("../utils/distance");
const { calculateHospitalScore } = require("../utils/hospitalScoring");

const diagnosePatient = async (req, res) => {

    try {
        const {
            age,
            sex,
            symptoms,
            existing_conditions,
            allergies,
            medications,
            additional_information,
            latitude,
            longitude
        } = req.body;
        
        const { data: aiResult } = await axios.post(
            process.env.AI_SERVICE_URL + "/analyze",
            {
                age,
                sex,
                symptoms,
                existing_conditions,
                allergies,
                medications,
                additional_information,
                latitude,
                longitude
            }
        );
        
        const requiredSpecialties = new Set();

        (aiResult.possible_conditions || []).forEach(condition => {

            const name = (
                condition.name ||
                condition.condition ||
                ""
            ).toLowerCase();

            if (
                name.includes("heart") ||
                name.includes("card") ||
                name.includes("angina") ||
                name.includes("pericard")
            ) {
                requiredSpecialties.add("Cardiology");
            }

            if (
                name.includes("brain") ||
                name.includes("stroke") ||
                name.includes("nerve") ||
                name.includes("sciatica")
            ) {
                requiredSpecialties.add("Neurology");
            }

            if (
                name.includes("fracture") ||
                name.includes("bone") ||
                name.includes("joint") ||
                name.includes("muscle")
            ) {
                requiredSpecialties.add("Orthopedics");
            }

            if (
                name.includes("lung") ||
                name.includes("asthma") ||
                name.includes("pneumonia")
            ) {
                requiredSpecialties.add("Pulmonology");
            }

            requiredSpecialties.add("General Medicine");

        });

        const searchRadius =
            aiResult.safety?.urgency === "emergency"
                ? 100000
                : 50000;

        const hospitals = await Hospital.find({
            isOpen: true,
            isVerified: true,
            location: {
                $near: {
                    $geometry: {
                        type: "Point",
                        coordinates: [longitude, latitude]
                    },
                    $maxDistance: searchRadius
                }
            }
        }).limit(50);

        const rankedHospitals = hospitals.map(hospital => {

            const distance = calculateDistance(
                latitude,
                longitude,
                hospital.location.coordinates[1],
                hospital.location.coordinates[0]
            );

            const score = calculateHospitalScore({
                hospital,
                requiredSpecialties: [...requiredSpecialties],
                urgency: aiResult.safety?.urgency || "routine",
                distance
            });

            const occupancy = (
                (hospital.currentPatients / hospital.maxCapacity) * 100
            ).toFixed(1);

            const matchedSpecialties = hospital.specialties.filter(s =>
                [...requiredSpecialties].includes(s)
            );

            const reasons = [];

            if (matchedSpecialties.length) {
                reasons.push(
                    `Has ${matchedSpecialties.join(", ")} specialists`
                );
            }

            if (distance <= 5) {
                reasons.push("Very close to your location");
            } else if (distance <= 15) {
                reasons.push("Reasonably close");
            }

            if (hospital.currentPatients < hospital.maxCapacity * 0.5) {
                reasons.push("Currently not congested");
            }

            if (hospital.averageWaitingTime <= 30) {
                reasons.push("Short waiting time");
            }

            if (
                aiResult.safety?.urgency === "emergency" &&
                hospital.emergency
            ) {
                reasons.push("Accepts emergency cases");
            }

            if (
                aiResult.safety?.urgency === "emergency" &&
                hospital.ambulanceAvailable
            ) {
                reasons.push("Ambulance service available");
            }

            return {
                ...hospital.toObject(),
                distance: Number(distance.toFixed(2)),
                score,
                occupancy: Number(occupancy),
                estimatedWaitingTime: hospital.averageWaitingTime,
                matchedSpecialties,
                whyRecommended: reasons
            };

        });

        rankedHospitals.sort((a, b) => {
            if (b.score === a.score) {
                return a.distance - b.distance;
            }
            return b.score - a.score;
        })
        const diagnosis = await Diagnosis.create({
            patient: req.user._id,
            symptoms,
            possibleConditions: aiResult.possible_conditions,
            severity: aiResult.severity,
            recommendations: aiResult.recommendations,
            recommendedHospitals: rankedHospitals
                .slice(0, 3)
                .map(h => h._id),

            safety: aiResult.safety
        });

        return res.status(200).json({
            success: true,
            diagnosisId: diagnosis._id,
            analysis: aiResult,
            recommended_hospitals: rankedHospitals.slice(0, 3)
        });
    } catch (error) {
        console.error(error.stack);

        return res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

module.exports = {
    diagnosePatient
};