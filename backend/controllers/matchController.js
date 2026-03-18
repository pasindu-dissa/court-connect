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

// @desc    Get all active matches
// @route   GET /api/matches
const getMatches = async (req, res) => {
  try {
    // --- 1. AUTO-EXPIRATION LOGIC (Date & Time) ---
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const todayStr = `${year}-${month}-${day}`;

    // Helper to convert "10:00 AM" to a 24-hour integer for easy comparison
    const convertTo24Hour = (timeStr) => {
      if (!timeStr) return 0;
      // If there are multiple slots, use the latest one to determine expiration
      const slots = timeStr.split(',').map(s => s.trim());
      const lastSlot = slots[slots.length - 1];
      
      const [time, modifier] = lastSlot.split(' ');
      let [hours, minutes] = time.split(':');
      hours = parseInt(hours, 10);
      if (hours === 12) hours = 0;
      if (modifier === 'PM') hours += 12;
      return hours * 100 + parseInt(minutes, 10);
    };

    const currentHourMin = now.getHours() * 100 + now.getMinutes();

    // Fetch all active matches to check them individually (since time logic requires JS parsing)
    const activeMatches = await Match.find({ status: { $ne: 'Completed' } });

    for (let match of activeMatches) {
      let isExpired = false;

      if (match.date < todayStr) {
        // Passed days are definitely expired
        isExpired = true;
      } else if (match.date === todayStr) {
        // If it's today, check if the time has passed
        const matchTime24 = convertTo24Hour(match.time);
        if (currentHourMin > matchTime24) {
          isExpired = true;
        }
      }

      if (isExpired) {
        match.status = 'Completed';
        await match.save();
      }
    }

    // --- 2. FETCH UPCOMING MATCHES ---
    // Now fetch only matches that are still NOT completed after the cleanup
    const upcomingMatches = await Match.find({ status: { $ne: 'Completed' } })
      .populate('hostId', 'name profileImage')
      .populate('joinedPlayers', 'name profileImage')
      .populate('pendingPlayers', 'name profileImage') 
      .sort({ date: 1, time: 1 }); // SORT: Closest upcoming date and time at the top!

    res.json(upcomingMatches);
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

const approvePlayer = async (req, res) => {
  try {
    const { playerId } = req.body;
    const match = await Match.findById(req.params.id);
    
    if (!match) return res.status(404).json({ message: 'Match not found' });
    if (match.currentPlayers >= match.maxPlayers) return res.status(400).json({ message: 'Match is full' });

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