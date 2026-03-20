const User = require("../models/User");

const evaluateBadges = async (userId) => {
  const user = await User.findById(userId);
  if (!user) return;

  const badges = new Set(user.badges);

  // Badge 1: First Win
  if (user.stats.wins >= 1) {
    badges.add("First Win 🏆");
  }

  // Badge 2: Played 5 Games
  if (user.stats.matchesPlayed >= 5) {
    badges.add("5 Matches Played 🎯");
  }

  // Badge 3: Win Streak
  const today = new Date().toDateString();
  const last = user.lastPlayedDate?.toDateString();

  if (last === today) {
    user.streak += 1;
  } else {
    user.streak = 1;
  }

  if (user.streak >= 3) {
    badges.add("3-Day Streak 🔥");
  }

  user.lastPlayedDate = new Date();
  user.badges = Array.from(badges);

  await user.save();
};

module.exports = { evaluateBadges };
