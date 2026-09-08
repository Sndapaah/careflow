const Hospital = require('../models/hospital');

const intervalMs = Math.max(
  60_000,
  Number(process.env.HOSPITAL_SIM_INTERVAL_MS || 180_000),
);

function bounded(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

async function refreshHospitalMetrics() {
  const hospitals = await Hospital.find({ isVerified: true }).select(
    '_id maxCapacity currentPatients availableBeds averageWaitingTime incomingPatients emergencies',
  );

  const operations = hospitals.map((hospital) => {
    const capacity = Math.max(1, hospital.maxCapacity || 1);
    const current = hospital.currentPatients || 0;
    const beds = hospital.availableBeds || 0;
    const patientDelta = Math.floor(Math.random() * 17) - 8;
    const nextPatients = bounded(current + patientDelta, 0, capacity);
    const bedDelta = current - nextPatients;
    const nextBeds = bounded(beds + bedDelta, 0, capacity);
    const occupancy = nextPatients / capacity;
    const waitDelta = Math.floor(Math.random() * 11) - 5;
    const nextWait = bounded(
      Math.round((hospital.averageWaitingTime || 0) + waitDelta + occupancy * 4),
      0,
      240,
    );
    const nextIncoming = bounded(
      (hospital.incomingPatients || 0) + Math.floor(Math.random() * 9) - 4,
      0,
      Math.max(5, Math.round(capacity * 0.2)),
    );
    const nextEmergencies = bounded(
      (hospital.emergencies || 0) + Math.floor(Math.random() * 5) - 2,
      0,
      Math.max(1, Math.round(nextPatients * 0.15)),
    );

    return Hospital.updateOne(
      { _id: hospital._id },
      {
        $set: {
          currentPatients: nextPatients,
          availableBeds: nextBeds,
          averageWaitingTime: nextWait,
          incomingPatients: nextIncoming,
          emergencies: nextEmergencies,
          lastUpdated: new Date(),
        },
      },
    );
  });

  await Promise.all(operations);
  console.log(`[hospital-simulator] refreshed ${hospitals.length} hospital(s)`);
}

function startHospitalSimulator() {
  if (process.env.HOSPITAL_SIMULATION === 'false') {
    console.log('[hospital-simulator] disabled');
    return null;
  }

  const timer = setInterval(() => {
    refreshHospitalMetrics().catch((error) =>
      console.error('[hospital-simulator] refresh failed:', error.message),
    );
  }, intervalMs);
  timer.unref();
  console.log(`[hospital-simulator] enabled; interval ${intervalMs}ms`);
  return timer;
}

module.exports = { refreshHospitalMetrics, startHospitalSimulator };
