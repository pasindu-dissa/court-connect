const Match = require('../models/Match');
const User = require('../models/User');

const createMatch = async (req, res) => {
  try {
    const { hostId } = req.body;
    const matchData = {
      ...req.body,
      joinedPlayers: [hostId],
      currentPlayers: 1
    };
    const match = await Match.create(matchData);
    res.status(201).json(match);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getMatches = async (req, res) => {
  try {
    // Populate pending players so the host can see them!
    const matches = await Match.find({ status: { $ne: 'Completed' } })
      .populate('hostId', 'name profileImage')
      .populate('joinedPlayers', 'name profileImage')
      .populate('pendingPlayers', 'name profileImage') 
      .sort({ createdAt: -1 });
    res.json(matches);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateMatch = async (req, res) => {
  try {
    const match = await Match.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!match) return res.status(404).json({ message: 'Match not found' });
    res.json(match);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Player requests to join
const requestJoin = async (req, res) => {
  try {
    const { userId } = req.body;
    const match = await Match.findById(req.params.id);
    
    if (!match) return res.status(404).json({ message: 'Match not found' });
    if (match.currentPlayers >= match.maxPlayers) return res.status(400).json({ message: 'Match is full' });
    if (match.joinedPlayers.includes(userId)) return res.status(400).json({ message: 'Already joined' });
    if (match.pendingPlayers.includes(userId)) return res.status(400).json({ message: 'Already requested' });

    match.pendingPlayers.push(userId);
    await match.save();
    res.json(match);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Host approves player
const approvePlayer = async (req, res) => {
  try {
    const { playerId } = req.body;
    const match = await Match.findById(req.params.id);
    
    if (!match) return res.status(404).json({ message: 'Match not found' });
    if (match.currentPlayers >= match.maxPlayers) return res.status(400).json({ message: 'Match is full' });

    // Remove from pending, add to joined
    match.pendingPlayers = match.pendingPlayers.filter(id => id.toString() !== playerId);
    if (!match.joinedPlayers.includes(playerId)) {
      match.joinedPlayers.push(playerId);
      match.currentPlayers += 1;
    }
    
    if (match.currentPlayers >= match.maxPlayers) match.status = 'Full';
    
    await match.save();
    res.json(match);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Host rejects player
const rejectPlayer = async (req, res) => {
  try {
    const { playerId } = req.body;
    const match = await Match.findById(req.params.id);
    if (!match) return res.status(404).json({ message: 'Match not found' });

    match.pendingPlayers = match.pendingPlayers.filter(id => id.toString() !== playerId);
    await match.save();
    res.json(match);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getOpponents = async (req, res) => {
  try {
    const opponents = await User.find({ role: 'player' }).select('name profileImage location skills stats district');
    res.json(opponents);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { createMatch, getMatches, updateMatch, requestJoin, approvePlayer, rejectPlayer, getOpponents };