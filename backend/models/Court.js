const mongoose = require('mongoose');

const courtSchema = mongoose.Schema(
  {
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    name: { type: String, required: true },
    location: { type: String, required: true }, // Display Address
    district: { type: String, required: true },
    
    // CHANGED: Support multiple sports
    sports: [{ type: String, required: true }], 
    
    pricePerHour: { type: Number, required: true },
    description: { type: String },
    images: [{ type: String }],
    amenities: [{ type: String }],
    contactNumber: { type: String },
    isOpen: { type: Boolean, default: true },
    
    // --- EXACT LOCATION DATA ---
    // Made optional because user might provide Plus Code instead
    latitude: { type: Number },
    longitude: { type: Number },
    plusCode: { type: String }, // New Field
    googleMapsLink: { type: String }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Court', courtSchema);