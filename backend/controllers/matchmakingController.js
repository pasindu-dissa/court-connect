const User = require('../models/User');

// @desc    Find suitable opponents based on Sport and Location
// @route   POST /api/matchmaking/find
// @access  Public (Protected in production)
const findOpponents = async (req, res) => {
  const { sport, location, userId } = req.body;

  try {
    // 1. Build the Query
    // We want users who:
    // - Are NOT the current user ($ne means "not equal")
    // - Have the same location (Regex for partial match, case-insensitive)
    // - Have the requested sport in their 'skills' array
    const query = {
      _id: { $ne: userId }, 
      location: { $regex: location, $options: 'i' },
      skills: { 
        $elemMatch: { sport: sport } 
      }
    };

    // 2. Execute Query
    // .select() means: "Only give me their name, image, and skills. Don't send their password!"
    const opponents = await User.find(query)
      .select('name profileImage location skills stats');

    // 3. Return Results
    res.json({
      count: opponents.length,
      opponents: opponents
    });

  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

module.exports = { findOpponents };