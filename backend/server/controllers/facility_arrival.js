const FacilityArrival = require('../models/facility_arrival');
const Hospital = require('../models/hospital');

const validLocation = (latitude, longitude) => Number.isFinite(latitude) && latitude >= -90 && latitude <= 90 && Number.isFinite(longitude) && longitude >= -180 && longitude <= 180;

const activeCount = (facility) => FacilityArrival.countDocuments({
  facility,
  status: 'active',
  lastSeenAt: { $gt: new Date(Date.now() - 10 * 60 * 1000) },
});

const startArrival = async (req, res) => {
  const { facilityId } = req.params;
  const { etaMinutes, latitude, longitude } = req.body;
  if (!Number.isFinite(etaMinutes) || etaMinutes < 0 || etaMinutes > 360) return res.status(400).json({ message: 'A valid ETA is required.' });
  if (!validLocation(latitude, longitude)) return res.status(400).json({ message: 'A valid location is required.' });
  if (!await Hospital.exists({ _id: facilityId, isOpen: true })) return res.status(404).json({ message: 'Facility not found or closed.' });
  await FacilityArrival.updateMany({ user: req.user._id, status: 'active' }, { $set: { status: 'cancelled' } });
  const arrival = await FacilityArrival.create({ facility: facilityId, user: req.user._id, etaMinutes, lastLocation: { type: 'Point', coordinates: [longitude, latitude] } });
  return res.status(201).json({ arrivalId: arrival._id, incomingPatients: await activeCount(facilityId) });
};

const heartbeatArrival = async (req, res) => {
  if (!Number.isFinite(req.body.etaMinutes) || req.body.etaMinutes < 0 || req.body.etaMinutes > 360) return res.status(400).json({ message: 'A valid ETA is required.' });
  if (!validLocation(req.body.latitude, req.body.longitude)) return res.status(400).json({ message: 'A valid location is required.' });
  const arrival = await FacilityArrival.findOneAndUpdate(
    { _id: req.params.arrivalId, facility: req.params.facilityId, user: req.user._id, status: 'active' },
    { $set: { etaMinutes: req.body.etaMinutes, lastSeenAt: new Date(), lastLocation: { type: 'Point', coordinates: [req.body.longitude, req.body.latitude] } } },
    { new: true },
  );
  if (!arrival) return res.status(404).json({ message: 'Arrival estimate is no longer active.' });
  return res.json({ incomingPatients: await activeCount(arrival.facility) });
};

const cancelArrival = async (req, res) => {
  const arrival = await FacilityArrival.findOneAndUpdate(
    { _id: req.params.arrivalId, facility: req.params.facilityId, user: req.user._id, status: 'active' },
    { $set: { status: 'cancelled' } },
  );
  if (!arrival) return res.status(404).json({ message: 'Arrival estimate is no longer active.' });
  return res.json({ incomingPatients: await activeCount(arrival.facility) });
};

module.exports = { activeCount, startArrival, heartbeatArrival, cancelArrival };
