const mongoose = require('mongoose');

const userSchema = mongoose.Schema(
  {
    firebaseUid: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    profileImage: { type: String, default: "" },
    phone: { type: String, default: ""},
    bio: {type: String, default: ""},
    age: { type: Number },
    district: { type: String },
    city: { type: String },
    location: { type: String, default: "Colombo" },
    fcmToken: { type: String, default: '' },
    notifications: [
      {
        title: String,
        body: String,
        type: { type: String, default: 'general' },
        read: { type: Boolean, default: false },
        createdAt: { type: Date, default: Date.now }
      }
    ],
    // --- ROLE MANAGEMENT ---
    // Change this manually in MongoDB to 'court_owner' for specific users
    role: { 
      type: String, 
      enum: ['player', 'court_owner', 'admin'], 
      default: 'player' 
    },

    // Player specific fields
    skills: [
      {
        sport: { type: String },
        level: { type: String, enum: ['Beginner', 'Intermediate', 'Pro'], default: 'Beginner' }
      }
    ],
    availability: [String], 
    stats: {
      matchesPlayed: { type: Number, default: 0 },
      wins: { type: Number, default: 0 },
      points: { type: Number, default: 0 }
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);