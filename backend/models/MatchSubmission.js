const mongoose = require("mongoose");

const MatchSubmissionSchema = new mongoose.Schema({
  matchId: {
    type: String,
    required: true
  },

  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  score: {
    teamA: Number,
    teamB: Number
  },

  submittedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("MatchSubmission", MatchSubmissionSchema);
