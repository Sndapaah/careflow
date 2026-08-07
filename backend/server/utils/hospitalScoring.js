function calculateHospitalScore({
    hospital,
    requiredSpecialties,
    distance,
    urgency
}) {

    let score = 0;

    const matched = hospital.specialties.filter(s =>
        requiredSpecialties.includes(s)
    ).length;

    if (requiredSpecialties.length) {
        score += (matched / requiredSpecialties.length) * 30;
    }

    if (distance <= 2) score += 20;
    else if (distance <= 5) score += 18;
    else if (distance <= 10) score += 15;
    else if (distance <= 20) score += 10;
    else if (distance <= 50) score += 5;

    const occupancy =
        hospital.currentPatients /
        Math.max(hospital.maxCapacity, 1);

    if (occupancy < 0.30) score += 20;
    else if (occupancy < 0.50) score += 16;
    else if (occupancy < 0.70) score += 12;
    else if (occupancy < 0.90) score += 6;
    else score += 1;

    if (hospital.averageWaitingTime <= 15) score += 10;
    else if (hospital.averageWaitingTime <= 30) score += 8;
    else if (hospital.averageWaitingTime <= 60) score += 6;
    else if (hospital.averageWaitingTime <= 120) score += 3;

    score += (hospital.rating / 5) * 10;

    if (
        urgency === "emergency" &&
        hospital.emergency
    ) {
        score += 5;
    }

    if (
        urgency === "emergency" &&
        hospital.ambulanceAvailable
    ) {
        score += 3;
    }

    if (
        urgency === "emergency" &&
        hospital.icuBeds > 0
    ) {
        score += 2;
    }

    return Number(score.toFixed(2));
}

module.exports = {
    calculateHospitalScore
};


































// function calculateHospitalScore({
//     hospital,
//     requiredSpecialties,
//     distance,
//     urgency
// }) {

//     let score = 0;

//     // Specialty Match (40)
//     const matched = hospital.specialties.filter(s =>
//         requiredSpecialties.includes(s)
//     ).length;

//     if (requiredSpecialties.length) {
//         score += (matched / requiredSpecialties.length) * 40;
//     }

//     // Distance (25)
//     if (distance <= 2) score += 25;
//     else if (distance <= 5) score += 20;
//     else if (distance <= 10) score += 15;
//     else if (distance <= 20) score += 10;
//     else score += 5;

//     // Capacity (15)
//     const occupancy =
//         hospital.currentPatients /
//         Math.max(hospital.maxCapacity, 1);

//     score += (1 - occupancy) * 15;

//     // Waiting Time (10)
//     if (hospital.averageWaitingTime <= 15) score += 10;
//     else if (hospital.averageWaitingTime <= 30) score += 8;
//     else if (hospital.averageWaitingTime <= 60) score += 6;
//     else if (hospital.averageWaitingTime <= 120) score += 3;

//     // Rating (5)
//     score += (hospital.rating / 5) * 5;

//     // Emergency (5)
//     if (
//         urgency === "emergency" &&
//         hospital.isAcceptingEmergencyCases
//     ) {
//         score += 5;
//     }

//     return Number(score.toFixed(2));
// }

// module.exports = {
//     calculateHospitalScore
// };