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
    '_id maxCapacity currentPatients availableBeds averageWaitingTime incomingPatients emergencies simulationDirection simulationStep',
  );

  const operations = hospitals.map((hospital) => {
    const capacity = Math.max(1, hospital.maxCapacity || 1);
    const current = hospital.currentPatients || 0;
    const beds = hospital.availableBeds || 0;
    const occupancy = current / capacity;
    let direction = Math.random() < 0.5 ? 'increasing' : 'decreasing';
    // Keep the cycle believable at the capacity boundaries.
    if (occupancy >= 0.85) direction = 'decreasing';
    if (occupancy <= 0.30) direction = 'increasing';
    const previousDirection = hospital.simulationDirection || 'increasing';
    const previousStep = bounded(hospital.simulationStep || 1, 1, 8);
    const step = direction === 'increasing'
      ? (previousDirection === 'increasing' ? Math.min(previousStep + 1, 8) : 1)
      : (Math.floor(Math.random() * 3) + 1);
    const patientDelta = direction === 'increasing' ? step : -step;
    const nextPatients = bounded(current + patientDelta, 0, capacity);
    const bedDelta = current - nextPatients;
    const nextBeds = bounded(beds + bedDelta, 0, capacity);
    const nextOccupancy = nextPatients / capacity;
    const nextIncoming = bounded(
      (hospital.incomingPatients || 0) + (direction === 'increasing'
        ? Math.floor(Math.random() * 5)
        : -Math.floor(Math.random() * 5)),
      0,
      Math.max(5, Math.round(capacity * 0.2)),
    );
    const nextEmergencies = bounded(
      (hospital.emergencies || 0) + (direction === 'increasing'
        ? Math.floor(Math.random() * 3)
        : -Math.floor(Math.random() * 3)),
      0,
      Math.max(1, Math.round(nextPatients * 0.15)),
    );

    // Waiting time is derived from the resulting operational state rather
    // than randomized independently. Higher occupancy, arrivals, and
    // emergencies increase the queue; available beds provide a small relief.
    const baselineWait = 5;
    const occupancyWait = nextOccupancy * 120;
    const incomingWait = nextIncoming * 1.5;
    const emergencyWait = nextEmergencies * 3;
    const bedRelief = nextBeds > capacity * 0.5 ? 5 : 0;
    const nextWait = bounded(
      Math.round(
        baselineWait + occupancyWait + incomingWait + emergencyWait - bedRelief,
      ),
      0,
      240,
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
          simulationDirection: direction,
          simulationStep: step,
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
