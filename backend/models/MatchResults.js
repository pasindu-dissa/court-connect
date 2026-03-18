const mongoose = require('mongoose');

const matchResultSchema = new mongoose.Schema({
  group: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Group',
    required: true
  },
  sport: {
    type: String,
    required: true,
    enum: ['basketball', 'volleyball', 'cricket', 'football', 'badminton', 'other']
  },
  team1: {
    name: { type: String, required: true },
    score: { type: Number, required: true, min: 0 }
  },
  team2: {
    name: { type: String, required: true },
    score: { type: Number, required: true, min: 0 }
  },
  matchDate: {
    type: Date,
    default: Date.now
  },
  venue: {
    type: String
  },
  winner: {
    type: String,
    enum: ['team1', 'team2', 'draw']
  },
  matchType: {
    type: String,
    enum: ['league', 'knockout', 'friendly', 'semifinal', 'final'],
    default: 'league'
  },
  recordedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  notes: {
    type: String
  }
}, {
  timestamps: true
});

// Determine winner before saving
matchResultSchema.pre('save', function(next) {
  if (this.team1.score > this.team2.score) {
    this.winner = 'team1';
  } else if (this.team2.score > this.team1.score) {
    this.winner = 'team2';
  } else {
    this.winner = 'draw';
  }
  next();
});

module.exports = mongoose.model('MatchResult', matchResultSchema);