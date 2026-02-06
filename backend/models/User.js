const mongoose = require('mongoose');

const userSchema = mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
    },
    profileImage: {
      type: String,
      default: "",
    },
    // --- MATCHMAKING FIELDS ---
    location: {
      type: String, // e.g., "Colombo"
      default: "Colombo",
    },
    // Example: [{ sport: "Tennis", level: "Pro" }, { sport: "Cricket", level: "Beginner" }]
    skills: [
      {
        sport: { type: String, required: true },
        level: { type: String, enum: ['Beginner', 'Intermediate', 'Pro'], default: 'Beginner' }
      }
    ],
    // Example: ["Mon-Morning", "Sat-Evening"]
    availability: [String], 
    
    // Stats for Leaderboard
    stats: {
      matchesPlayed: { type: Number, default: 0 },
      wins: { type: Number, default: 0 },
      points: { type: Number, default: 0 } // For the Leaderboard
    }
  },
  {
    timestamps: true, // Automatically adds createdAt and updatedAt
  }
);

module.exports = mongoose.model('User', userSchema);