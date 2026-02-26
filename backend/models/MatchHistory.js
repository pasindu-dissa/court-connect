const mongoose = require("mongoose");

const MatchHistorySchema = new mongoose.Schema({
  matchId: {
    type: String,
    unique: true
  },

  sport: String,

  players: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User"
    }
  ],

  finalScore: {
    teamA: Number,
    teamB: Number
  },

  winnerTeam: String,

  playedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("MatchHistory", MatchHistorySchema);
