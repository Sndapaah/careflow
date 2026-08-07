const mongoose = require("mongoose");

const hospitalSchema = new mongoose.Schema({
    name: {
        type:String,
        required:true
    },
    image:String,
    address:String,
    city:String,
    region:String,
    phone:String,
    email:String,
    location: {
        type: {
            type: String,
            enum: ["Point"],
            default: "Point"
        },
        coordinates: {
            type: [Number], // [longitude, latitude]
            required: true
        }
    },
    specialties:[
        { type:String}
    ],
    emergency: {
        type:Boolean,
        default:false
    },
    rating: {
        type:Number,
        default:5
    },
    
    // Capacity
    maxCapacity: {
        type:Number,
        required:true
    },
    currentPatients: {
        type:Number,
        default:0
    },
    availableDoctors: {
        type:Number,
        default:0
    },
    availableBeds: {
        type:Number,
        default:0
    },
    averageWaitingTime: {
        type:Number,
        default:0
    },
    isAcceptingEmergencyCases: {
        type:Boolean,
        default:true
    },
    isOpen: {
        type:Boolean,
        default:true
    },
    isVerified: {
        type:Boolean,
        default:true
    },
    hospitalType: {
        type: String,
        enum: [
            "Teaching",
            "Regional",
            "Municipal",
            "District",
            "Private",
            "Mission",
            "Specialist"
        ]
    },
    services: [String],
    insuranceAccepted: [String],
    ambulanceAvailable: Boolean,
    icuBeds: Number,
    operatingTheatres: Number,
    lastUpdated: {
        type: Date,
        default: Date.now
    }
}, { timestamps:true });

hospitalSchema.index({
    location: "2dsphere"
});

const Hospital = mongoose.model("Hospital", hospitalSchema);
module.exports = Hospital;