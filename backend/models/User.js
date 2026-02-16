const mongoose = require("mongoose");

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
    age: { type: Number },

    district: { type: String },

    city: { type: String },
    // 'location' field already exists, we will map "City, District" to it.
    
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
        level: {
          type: String,
          enum: ["Beginner", "Intermediate", "Pro"],
          default: "Beginner",
        },
      },
    ],
    // Example: ["Mon-Morning", "Sat-Evening"]
    availability: [String],

    // Stats for Leaderboard
    stats: {
      matchesPlayed: { type: Number, default: 0 },
      wins: { type: Number, default: 0 },
      points: { type: Number, default: 0 }, // For the Leaderboard
    },

    // ---------------- GAMIFICATION ----------------
    badges: {
      type: [String],
      default: [],
    },

    lastPlayedDate: {
      type: Date,
    },

    streak: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true, // Automatically adds createdAt and updatedAt
  },
);

module.exports = mongoose.model("User", userSchema);
