const Team = require('../models/Team');

exports.createTeam = async (req, res) => {
  try {
    const { name, sport } = req.body;
    const team = await Team.create({
      name,
      sport,
      captain: req.user._id,
      members: [req.user._id]
    });
    res.status(201).json(team);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.joinTeam = async (req, res) => {
  try {
    const { teamId } = req.body;
    const team = await Team.findById(teamId);
    if (!team) return res.status(404).json({ message: 'Team not found' });
    if (team.members.includes(req.user._id)) return res.status(400).json({ message: 'User already in team' });
    
    team.members.push(req.user._id);
    await team.save();
    res.status(200).json(team);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getTeamById = async (req, res) => {
  try {
    const team = await Team.findById(req.params.id).populate('captain members', 'name email skill');
    if (!team) return res.status(404).json({ message: 'Team not found' });
    res.json(team);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};