const mongoose = require("mongoose");

const diagnosisSchema = new mongoose.Schema({

    patient: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },

    symptoms: [{
        name: String,
        severity: String,
        duration: String
    }],

    possibleConditions: [{
        name: String,
        probability: Number,
        severity: String,
        reason: String
    }],

    severity: {
        level: String,
        reason: String
    },

    recommendations: [String],

    recommendedHospitals: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Hospital"
    }],

    safety: Object,

    createdAt: {
        type: Date,
        default: Date.now
    }

});

const Diagnosis = mongoose.model("Diagnosis", diagnosisSchema);

module.exports = Diagnosis;