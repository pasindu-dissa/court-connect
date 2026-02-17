const mongoose = require('mongoose');

const matchSchema = mongoose.Schema(
  {
    hostId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    sport: { type: String, required: true },
    courtName: { type: String, required: true },
    location: { type: String, required: true },
    lat: { type: Number, required: true }, // For Map
    lng: { type: Number, required: true }, // For Map
    date: { type: Date, required: true }, // Stores both date and time
    skillLevel: { type: String, enum: ['Beginner', 'Intermediate', 'Pro', 'All Levels'], default: 'All Levels' },
    fee: { type: Number, default: 0 },
    maxPlayers: { type: Number, required: true },
    currentPlayers: { type: Number, default: 1 },
    joinedPlayers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // List of user IDs
    status: { type: String, enum: ['Open', 'Full', 'Completed'], default: 'Open' }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Match', matchSchema);