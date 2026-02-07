const MatchSubmission = require("../models/MatchSubmission");
const MatchHistory = require("../models/MatchHistory");
const User = require("../models/User");
const gamificationController = require("./gamificationController");

exports.submitScore = async (req, res) => {
  const { matchId, userId, score, players, sport } = req.body;

  try {
    // Save submission
    await MatchSubmission.create({ matchId, userId, score });

    // Get all submissions for this match
    const submissions = await MatchSubmission.find({ matchId });

    // Count identical scores
    const scoreMap = {};
    submissions.forEach(s => {
      const key = `${s.score.teamA}-${s.score.teamB}`;
      scoreMap[key] = (scoreMap[key] || 0) + 1;
    });

    const totalPlayers = players.length;
    let acceptedScore = null;

    for (const key in scoreMap) {
      if (scoreMap[key] / totalPlayers >= 0.7) {
        acceptedScore = key;
        break;
      }
    }

    if (!acceptedScore) {
      return res.json({
        success: false,
        message: "Waiting for more matching submissions"
      });
    }

    // Finalize match
    const [teamA, teamB] = acceptedScore.split("-").map(Number);
    const winnerTeam = teamA > teamB ? "A" : "B";

    await MatchHistory.create({
      matchId,
      sport,
      players,
      finalScore: { teamA, teamB },
      winnerTeam
    });

    // Update user stats
    for (const user of players) {
      const isWinner = user.team === winnerTeam;

      await User.findByIdAndUpdate(user.userId, {
        $inc: {
          "stats.matchesPlayed": 1,
          "stats.wins": isWinner ? 1 : 0,
          "stats.losses": isWinner ? 0 : 1,
          "stats.points": isWinner ? 3 : 0
        }
      });

      await gamificationController.evaluateBadges(user.userId);
    }

    // Clear temp submissions
    await MatchSubmission.deleteMany({ matchId });

    res.json({
      success: true,
      message: "Match verified and finalized"
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Score verification failed" });
  }
};
