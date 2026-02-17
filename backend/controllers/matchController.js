const Match = require('../models/Match');

// @desc    Get all available matches (with optional filters)
// @route   GET /api/matches
const getMatches = async (req, res) => {
  try {
    const { sport, location } = req.query;
    
    let query = { status: 'Open' }; // Only show open matches
    
    if (sport) query.sport = sport;
    if (location) query.location = { $regex: location, $options: 'i' }; // Partial match

    const matches = await Match.find(query).populate('hostId', 'name profileImage');
    
    res.json(matches);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a new match
// @route   POST /api/matches
const createMatch = async (req, res) => {
  try {
    const { hostId, sport, courtName, location, lat, lng, date, skillLevel, fee, maxPlayers } = req.body;

    const match = await Match.create({
      hostId,
      sport,
      courtName,
      location,
      lat,
      lng,
      date,
      skillLevel,
      fee,
      maxPlayers,
      currentPlayers: 1,
      joinedPlayers: [hostId] // Host is automatically joined
    });

    res.status(201).json(match);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

module.exports = { getMatches, createMatch };