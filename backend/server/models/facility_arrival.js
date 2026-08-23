const mongoose = require('mongoose');

const facilityArrivalSchema = new mongoose.Schema({
  facility: { type: mongoose.Schema.Types.ObjectId, ref: 'Hospital', required: true, index: true },
  user: { type: mongoose.Schema.Types.ObjectId, required: true },
  etaMinutes: { type: Number, min: 0, max: 360, required: true },
  lastLocation: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], required: true },
  },
  status: { type: String, enum: ['active', 'arrived', 'cancelled'], default: 'active', index: true },
  lastSeenAt: { type: Date, default: Date.now, expires: 900 },
}, { timestamps: true });

facilityArrivalSchema.index({ facility: 1, user: 1, status: 1 });
module.exports = mongoose.model('FacilityArrival', facilityArrivalSchema);
