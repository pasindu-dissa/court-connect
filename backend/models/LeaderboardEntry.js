const mongoose = require('mongoose');

const leaderboardEntrySchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    courtId: {
      type: mongoose.Schema.Types.ObjectId,
      // Change to match your court model name if it exists (e.g., 'Court')
      // For now, representing just as a string/objectId reference
      required: true
    },
    sportType: {
      type: String,
      required: true
    },
    points: {
      type: Number,
      default: 0
    }
  },
  { timestamps: true }
);

// Compound index to quickly find a user's score for a specific sport and court
leaderboardEntrySchema.index({ user: 1, courtId: 1, sportType: 1 }, { unique: true });
// Index for efficiently fetching top players by sport and court
leaderboardEntrySchema.index({ courtId: 1, sportType: 1, points: -1 });

module.exports = mongoose.model('LeaderboardEntry', leaderboardEntrySchema);
