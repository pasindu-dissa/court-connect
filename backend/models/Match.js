const mongoose = require('mongoose');

const matchSchema = mongoose.Schema(
  {
    hostId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    title: { type: String, required: true },
    sport: { type: String, required: true },
    courtName: { type: String, required: true },
    location: { type: String, required: true },
    date: { type: String }, 
    time: { type: String, required: true },
    skill: { type: String, default: "All Levels" },
    fee: { type: Number, default: 0 },
    currentPlayers: { type: Number, default: 1 },
    maxPlayers: { type: Number, required: true },
    
    // Players who are confirmed
    joinedPlayers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], 
    // Players waiting for host approval
    pendingPlayers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], 
    
    latitude: { type: Number },
    longitude: { type: Number },
    image: { type: String, default: "https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5" },
    status: { type: String, enum: ['Open', 'Full', 'Completed'], default: 'Open' }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Match', matchSchema);