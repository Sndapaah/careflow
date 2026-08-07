/**
 * One-off seed script — populates the Hospital collection with real
 * Kumasi-area facilities so /api/hospitals/recommend and /api/diagnosis/diagnose
 * have data to rank instead of returning empty arrays.
 *
 * Run from the server/ directory:
 *   node seed_hospitals.js
 *
 * Safe to re-run: it clears existing Hospital documents first, so running it
 * twice won't create duplicates.
 */

const mongoose = require("mongoose");
const dotenv = require("dotenv");
const Hospital = require("./models/hospital");

dotenv.config();

const hospitals = [
  {
    name: "Komfo Anokye Teaching Hospital",
    address: "Bantama High Street",
    city: "Kumasi",
    region: "Ashanti",
    phone: "+233 32 202 2308",
    email: "info@kath.gov.gh",
    location: { type: "Point", coordinates: [-1.6244, 6.6886] },
    specialties: [
      "Cardiology",
      "Neurology",
      "Orthopedics",
      "Pulmonology",
      "General Medicine",
      "Pediatrics",
      "Obstetrics",
    ],
    emergency: true,
    rating: 4.2,
    maxCapacity: 1200,
    currentPatients: 780,
    availableDoctors: 45,
    availableBeds: 120,
    averageWaitingTime: 52,
    isAcceptingEmergencyCases: true,
    isOpen: true,
    isVerified: true,
    hospitalType: "Teaching",
    services: ["Emergency Care", "Surgery", "ICU", "Imaging", "Laboratory"],
    insuranceAccepted: ["NHIS", "Private"],
    ambulanceAvailable: true,
    icuBeds: 24,
    operatingTheatres: 8,
  },
  {
    name: "KNUST Hospital",
    address: "KNUST Campus, Ayeduase",
    city: "Kumasi",
    region: "Ashanti",
    phone: "+233 32 206 0400",
    email: "hospital@knust.edu.gh",
    location: { type: "Point", coordinates: [-1.5661, 6.6746] },
    specialties: ["General Medicine", "Pulmonology", "Orthopedics"],
    emergency: true,
    rating: 4.0,
    maxCapacity: 60,
    currentPatients: 21,
    availableDoctors: 9,
    availableBeds: 20,
    averageWaitingTime: 18,
    isAcceptingEmergencyCases: true,
    isOpen: true,
    isVerified: true,
    hospitalType: "Regional",
    services: ["Emergency", "Out-Patient Department", "Pharmacy", "Laboratory", "Radiology"],
    insuranceAccepted: ["NHIS", "Private"],
    ambulanceAvailable: true,
    icuBeds: 4,
    operatingTheatres: 2,
  },
  {
    name: "University Clinic (KNUST)",
    address: "KNUST Campus, near Commercial Area",
    city: "Kumasi",
    region: "Ashanti",
    phone: "+233 32 206 0331",
    email: "clinic@knust.edu.gh",
    location: { type: "Point", coordinates: [-1.5716, 6.6745] },
    specialties: ["General Medicine"],
    emergency: false,
    rating: 3.8,
    maxCapacity: 12,
    currentPatients: 4,
    availableDoctors: 3,
    availableBeds: 3,
    averageWaitingTime: 7,
    isAcceptingEmergencyCases: false,
    isOpen: true,
    isVerified: true,
    hospitalType: "District",
    services: ["Out-Patient Department", "Pharmacy", "Laboratory"],
    insuranceAccepted: ["NHIS"],
    ambulanceAvailable: false,
    icuBeds: 0,
    operatingTheatres: 0,
  },
  {
    name: "Bomso Hospital",
    address: "Bomso Road",
    city: "Kumasi",
    region: "Ashanti",
    phone: "+233 32 208 4411",
    email: "info@bomsohospital.com",
    location: { type: "Point", coordinates: [-1.5850, 6.6790] },
    specialties: ["General Medicine", "Orthopedics", "Pediatrics"],
    emergency: true,
    rating: 4.1,
    maxCapacity: 80,
    currentPatients: 28,
    availableDoctors: 12,
    availableBeds: 40,
    averageWaitingTime: 26,
    isAcceptingEmergencyCases: true,
    isOpen: true,
    isVerified: true,
    hospitalType: "Private",
    services: ["Emergency Care", "Surgery", "Maternity", "Laboratory"],
    insuranceAccepted: ["NHIS", "Private"],
    ambulanceAvailable: true,
    icuBeds: 6,
    operatingTheatres: 3,
  },
  {
    name: "Suntreso Government Hospital",
    address: "Suntreso",
    city: "Kumasi",
    region: "Ashanti",
    phone: "+233 32 202 4567",
    email: "info@suntresohospital.gov.gh",
    location: { type: "Point", coordinates: [-1.6520, 6.6980] },
    specialties: ["General Medicine", "Pulmonology", "Obstetrics"],
    emergency: true,
    rating: 3.9,
    maxCapacity: 150,
    currentPatients: 95,
    availableDoctors: 18,
    availableBeds: 55,
    averageWaitingTime: 40,
    isAcceptingEmergencyCases: true,
    isOpen: true,
    isVerified: true,
    hospitalType: "Municipal",
    services: ["Emergency Care", "Maternity", "Pharmacy", "Laboratory"],
    insuranceAccepted: ["NHIS"],
    ambulanceAvailable: true,
    icuBeds: 8,
    operatingTheatres: 4,
  },
  {
    name: "Ridge Medical Centre",
    address: "Ridge",
    city: "Kumasi",
    region: "Ashanti",
    phone: "+233 32 208 7789",
    email: "contact@ridgemedical.com",
    location: { type: "Point", coordinates: [-1.6180, 6.6790] },
    specialties: ["Cardiology", "General Medicine"],
    emergency: false,
    rating: 4.4,
    maxCapacity: 40,
    currentPatients: 10,
    availableDoctors: 7,
    availableBeds: 18,
    averageWaitingTime: 15,
    isAcceptingEmergencyCases: false,
    isOpen: true,
    isVerified: true,
    hospitalType: "Private",
    services: ["Out-Patient Department", "Cardiac Screening", "Laboratory"],
    insuranceAccepted: ["Private"],
    ambulanceAvailable: false,
    icuBeds: 2,
    operatingTheatres: 1,
  },
  {
    name: "Manhyia District Hospital",
    address: "Manhyia",
    city: "Kumasi",
    region: "Ashanti",
    phone: "+233 32 204 3321",
    email: "info@manhyiahospital.gov.gh",
    location: { type: "Point", coordinates: [-1.6100, 6.7050] },
    specialties: ["General Medicine", "Pediatrics"],
    emergency: true,
    rating: 3.7,
    maxCapacity: 70,
    currentPatients: 30,
    availableDoctors: 8,
    availableBeds: 25,
    averageWaitingTime: 34,
    isAcceptingEmergencyCases: true,
    isOpen: true,
    isVerified: true,
    hospitalType: "District",
    services: ["Emergency Care", "Out-Patient Department", "Pharmacy"],
    insuranceAccepted: ["NHIS"],
    ambulanceAvailable: true,
    icuBeds: 3,
    operatingTheatres: 1,
  },
];

async function seed() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("Connected to MongoDB.");

    const deleted = await Hospital.deleteMany({});
    console.log(`Cleared ${deleted.deletedCount} existing hospital record(s).`);

    const inserted = await Hospital.insertMany(hospitals);
    console.log(`Seeded ${inserted.length} hospitals:`);
    inserted.forEach((h) => console.log(`  - ${h.name} (${h._id})`));

    await mongoose.disconnect();
    console.log("Done. Disconnected.");
    process.exit(0);
  } catch (err) {
    console.error("Seed failed:", err);
    process.exit(1);
  }
}

seed();