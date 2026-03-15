const mongoose = require('mongoose');

const leaderboardSchema = new mongoose.Schema({
  group: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Group',
    required: true
  },
  teamName: {
    type: String,
    required: true
  },
  sport: {
    type: String,
    required: true,
    enum: ['basketball', 'volleyball', 'cricket', 'football', 'badminton', 'other']
  },
  matchesPlayed: {
    type: Number,
    default: 0
  },
  matchesWon: {
    type: Number,
    default: 0
  },
  matchesLost: {
    type: Number,
    default: 0
  },
  matchesDraw: {
    type: Number,
    default: 0
  },
  points: {
    type: Number,
    default: 0
  },
  goalsFor: {
    type: Number,
    default: 0
  },
  goalsAgainst: {
    type: Number,
    default: 0
  },
  goalDifference: {
    type: Number,
    default: 0
  },
  updatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  notes: {
    type: String
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Create compound index for group and teamName
leaderboardSchema.index({ group: 1, teamName: 1 }, { unique: true });

// Calculate goal difference before saving
leaderboardSchema.pre('save', function(next) {
  this.goalDifference = this.goalsFor - this.goalsAgainst;
  next();
});

// Virtual for win percentage
leaderboardSchema.virtual('winPercentage').get(function() {
  if (this.matchesPlayed === 0) return 0;
  return ((this.matchesWon / this.matchesPlayed) * 100).toFixed(2);
});

leaderboardSchema.set('toJSON', { virtuals: true });
leaderboardSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Leaderboard', leaderboardSchema);