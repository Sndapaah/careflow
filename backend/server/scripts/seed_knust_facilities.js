const dotenv = require('dotenv');
const mongoose = require('mongoose');
const Hospital = require('../models/hospital');

dotenv.config({ path: require('path').resolve(__dirname, '..', '.env') });

// Coordinates are [longitude, latitude] for MongoDB GeoJSON.
// These facilities are seeded with conservative demo capacity values; update
// phone, hours, capacity, and services with confirmed provider data before a
// production launch.
const facilities = [
  {
    name: 'KNUST Hospital (University Health Services, KNUST)',
    address: 'N6 (Tech Junction), KNUST Campus, Kumasi, Ashanti Region',
    city: 'Kumasi', region: 'Ashanti',
    location: { type: 'Point', coordinates: [-1.574171, 6.6859234] },
    specialties: ['General Medicine', 'Internal Medicine', 'Emergency Medicine', 'Surgery', 'Radiology', 'Pathology', 'Pediatrics', 'Obstetrics & Gynecology', 'Urology', 'Dentistry', 'Ophthalmology'],
    services: ['Outpatient care', 'Emergency care', 'Laboratory', 'Pharmacy', 'Radiology'],
    emergency: true, ambulanceAvailable: true, hospitalType: 'Teaching',
    phone: '+233 32 206 0320',
    maxCapacity: 150, availableBeds: 42, currentPatients: 108,
    availableDoctors: 14, incomingPatients: 12, emergencies: 5, averageWaitingTime: 35,
  },
  {
    name: 'KNUST Student Clinic',
    address: 'Near Hall 7 and University Hall, KNUST Campus, Kumasi',
    city: 'Kumasi', region: 'Ashanti',
    location: { type: 'Point', coordinates: [-1.5739179, 6.6803709] },
    specialties: ['General Medicine', 'Family Medicine'],
    services: ['Primary care', 'Student health', 'First aid', 'Pharmacy'],
    emergency: false, ambulanceAvailable: false, hospitalType: 'Specialist',
    maxCapacity: 5, availableBeds: 1, currentPatients: 4,
    availableDoctors: 2, incomingPatients: 1, emergencies: 0, averageWaitingTime: 15,
  },
  {
    name: 'Ayeduase Health Centre',
    address: 'Ayeduase, Kumasi', city: 'Kumasi', region: 'Ashanti',
    location: { type: 'Point', coordinates: [-1.56101, 6.67578] },
    specialties: ['General Medicine', 'Family Medicine', 'Maternal Health'],
    services: ['Primary care', 'Maternal health', 'Laboratory'],
    emergency: false, ambulanceAvailable: false, hospitalType: 'District',
    maxCapacity: 30, availableBeds: 9, currentPatients: 21,
    availableDoctors: 8, incomingPatients: 3, emergencies: 1, averageWaitingTime: 25,
  },
  {
    name: 'Bomso Clinic',
    address: 'Bomso, Kumasi', city: 'Kumasi', region: 'Ashanti',
    location: { type: 'Point', coordinates: [-1.5788, 6.6845] },
    specialties: ['General Medicine', 'Obstetrics & Gynecology', 'Pediatrics', 'Surgery', 'Diagnostics'],
    services: ['Outpatient care', 'Emergency care', 'Laboratory', 'Pharmacy', 'Ambulance'],
    emergency: true, ambulanceAvailable: true, hospitalType: 'Private',
    maxCapacity: 40, availableBeds: 12, currentPatients: 28,
    availableDoctors: 6, incomingPatients: 5, emergencies: 2, averageWaitingTime: 20,
  },
  {
    name: 'Kumasi South Hospital',
    address: 'Asokwa, Kumasi', city: 'Kumasi', region: 'Ashanti',
    location: { type: 'Point', coordinates: [-1.5847, 6.6525] },
    specialties: ['General Medicine', 'Emergency Medicine', 'Pediatrics'],
    services: ['Outpatient care', 'Emergency care', 'Laboratory', 'Maternity'],
    emergency: true, ambulanceAvailable: true, hospitalType: 'Regional',
    maxCapacity: 220, availableBeds: 60, currentPatients: 132,
    availableDoctors: 22, incomingPatients: 14, emergencies: 6, averageWaitingTime: 35,
  },
  {
    name: 'KsTU Clinic',
    address: 'Opposite Asem School Park, Kumasi Technical University campus', city: 'Kumasi', region: 'Ashanti',
    location: { type: 'Point', coordinates: [-1.6248, 6.6920] },
    specialties: ['General Medicine', 'Family Medicine'],
    services: ['Primary care', 'First aid', 'Pharmacy'],
    emergency: false, ambulanceAvailable: false, hospitalType: 'Specialist',
    phone: '+233 200 213 803',
    maxCapacity: 1, availableBeds: 0, currentPatients: 1,
    availableDoctors: 2, incomingPatients: 2, emergencies: 0, averageWaitingTime: 15,
  },
  {
    name: 'Komfo Anokye Teaching Hospital',
    address: 'Bantama, Kumasi', city: 'Kumasi', region: 'Ashanti',
    location: { type: 'Point', coordinates: [-1.631690, 6.697479] },
    specialties: ['General Medicine', 'Emergency Medicine', 'Surgery', 'Pediatrics', 'Obstetrics & Gynecology', 'Cardiology', 'Neurology'],
    services: ['Tertiary referral care', 'Emergency care', 'Laboratory', 'Pharmacy', 'Radiology', 'ICU'],
    emergency: true, ambulanceAvailable: true, hospitalType: 'Teaching',
    maxCapacity: 1200, availableBeds: 300, currentPatients: 760,
    availableDoctors: 100, incomingPatients: 38, emergencies: 20, averageWaitingTime: 45,
  },
];

async function run() {
  if (!process.env.MONGO_URI) throw new Error('MONGO_URI is not configured');
  await mongoose.connect(process.env.MONGO_URI);
  for (const facility of facilities) {
    await Hospital.updateOne(
      { name: facility.name, city: facility.city },
      { $set: { ...facility, isOpen: true, isVerified: true } },
      { upsert: true },
    );
  }
  console.log(`Ensured ${facilities.length} Kumasi facilities; existing records were preserved.`);
  await mongoose.disconnect();
}

run().catch(async (error) => {
  console.error(error);
  await mongoose.disconnect();
  process.exitCode = 1;
});
