const Hospital = require("../models/hospital");
const { calculateDistance } = require("../utils/distance");
const { calculateHospitalScore } = require("../utils/hospitalScoring");
const { activeCount } = require('./facility_arrival');

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

        const rankedHospitals = await Promise.all(hospitals.map(async hospital => {
            const incomingPatients = await activeCount(hospital._id);

            const distance = calculateDistance(
                latitude,
                longitude,
                hospital.latitude,
                hospital.longitude
            );

            const score = calculateHospitalScore({
                hospital: {
                    ...hospital.toObject(),
                    currentPatients: hospital.currentPatients + incomingPatients
                },
                requiredSpecialties: required_specialties,
                distance,
                urgency
            });

            return {
                ...hospital.toObject(),
                incomingPatients,
                distance,
                score
            };

        }));

        rankedHospitals.sort((a, b) => b.score - a.score);

        if (urgency === 'emergency') {
            const emergencyFacilities = rankedHospitals.filter((hospital) =>
                hospital.emergency === true && hospital.isAcceptingEmergencyCases !== false
            );
            const wellResourced = emergencyFacilities.filter((hospital) =>
                hospital.maxCapacity > 0 && (hospital.availableBeds / hospital.maxCapacity) >= 0.6
            );
            const candidates = wellResourced.length > 0 ? wellResourced : emergencyFacilities;
            if (candidates.length > 0) {
                const selected = candidates[0];
                const hasSafeBedCapacity = selected.maxCapacity > 0 &&
                    (selected.availableBeds / selected.maxCapacity) >= 0.6;
                selected.whyRecommended = [
                    ...(selected.whyRecommended || []),
                    ...(hasSafeBedCapacity
                        ? ['Emergency-enabled facility with at least 60% beds available.']
                        : ['Call the facility before travelling: no nearby emergency facility has at least 60% beds available.'])
                ];
                return res.status(200).json({ success: true, hospitals: [selected] });
            }
            return res.status(200).json({ success: true, hospitals: [] });
        }

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
