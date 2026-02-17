const mongoose = require('mongoose');

const courtSchema = mongoose.Schema(
  {
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    name: { type: String, required: true },
    location: { type: String, required: true }, // Display Address (e.g. "Colombo 7")
    district: { type: String, required: true },
    sport: { type: String, required: true },
    pricePerHour: { type: Number, required: true },
    description: { type: String },
    images: [{ type: String }],
    amenities: [{ type: String }],
    contactNumber: { type: String },
    isOpen: { type: Boolean, default: true },
    
    // --- EXACT LOCATION DATA ---
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    googleMapsLink: { type: String } // Optional direct link
  },
  { timestamps: true }
);

module.exports = mongoose.model('Court', courtSchema);