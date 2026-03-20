const Leaderboard = require('../models/Leaderboard');
const MatchResult = require('../models/MatchResults');
const Group = require('../models/Group');

// @desc    Get leaderboard for a specific group
// @route   GET /api/leaderboard/:groupId
// @access  Public
exports.getLeaderboard = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { sport } = req.query;

    const query = { group: groupId, isActive: true };
    if (sport) {
      query.sport = sport;
    }

    const leaderboard = await Leaderboard.find(query)
      .populate('group', 'name')
      .populate('updatedBy', 'name email')
      .sort({ points: -1, goalDifference: -1, goalsFor: -1 })
      .lean();

    const rankedLeaderboard = leaderboard.map((entry, index) => ({
      ...entry,
      rank: index + 1
    }));

    res.status(200).json({
      success: true,
      count: rankedLeaderboard.length,
      data: rankedLeaderboard
    });
  } catch (error) {
    console.error('Get leaderboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching leaderboard',
      error: error.message
    });
  }
};

// @desc    Get all leaderboards (for all groups)
// @route   GET /api/leaderboard
// @access  Public
exports.getAllLeaderboards = async (req, res) => {
  try {
    const { sport, limit = 10 } = req.query;

    const query = { isActive: true };
    if (sport) {
      query.sport = sport;
    }

    const leaderboard = await Leaderboard.find(query)
      .populate('group', 'name')
      .populate('updatedBy', 'name email')
      .sort({ points: -1, goalDifference: -1, goalsFor: -1 })
      .limit(parseInt(limit))
      .lean();

    res.status(200).json({
      success: true,
      count: leaderboard.length,
      data: leaderboard
    });
  } catch (error) {
    console.error('Get all leaderboards error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching leaderboards',
      error: error.message
    });
  }
};

// @desc    Initialize leaderboard for a group with teams
// @route   POST /api/leaderboard/initialize
// @access  Private (Court Manager only)
exports.initializeLeaderboard = async (req, res) => {
  try {
    const { groupId, teams, sport } = req.body;

    // Validate group exists
    const group = await Group.findById(groupId);
    if (!group) {
      return res.status(404).json({
        success: false,
        message: 'Group not found'
      });
    }

    const leaderboardEntries = [];
    for (const teamName of teams) {
      const entry = await Leaderboard.create({
        group: groupId,
        teamName,
        sport,
        updatedBy: req.user.id
      });
      leaderboardEntries.push(entry);
    }

    res.status(201).json({
      success: true,
      message: 'Leaderboard initialized successfully',
      data: leaderboardEntries
    });
  } catch (error) {
    console.error('Initialize leaderboard error:', error);
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Team already exists in this group leaderboard'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Error initializing leaderboard',
      error: error.message
    });
  }
};

// @desc    Record a match result and update leaderboard
// @route   POST /api/leaderboard/match-result
// @access  Private (Court Manager only)
exports.recordMatchResult = async (req, res) => {
  try {
    const {
      groupId,
      sport,
      team1Name,
      team1Score,
      team2Name,
      team2Score,
      matchDate,
      venue,
      matchType,
      notes
    } = req.body;

    if (!groupId || !sport || !team1Name || !team2Name) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields'
      });
    }

    if (team1Score === undefined || team2Score === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Please provide scores for both teams'
      });
    }

    const matchResult = await MatchResult.create({
      group: groupId,
      sport,
      team1: {
        name: team1Name,
        score: team1Score
      },
      team2: {
        name: team2Name,
        score: team2Score
      },
      matchDate: matchDate || Date.now(),
      venue,
      matchType: matchType || 'league',
      recordedBy: req.user.id,
      notes
    });

    await updateTeamStats(groupId, team1Name, team1Score, team2Score, req.user.id);
    await updateTeamStats(groupId, team2Name, team2Score, team1Score, req.user.id);

    const updatedLeaderboard = await Leaderboard.find({ group: groupId, sport })
      .sort({ points: -1, goalDifference: -1, goalsFor: -1 })
      .lean();

    res.status(201).json({
      success: true,
      message: 'Match result recorded and leaderboard updated',
      data: {
        matchResult,
        leaderboard: updatedLeaderboard
      }
    });
  } catch (error) {
    console.error('Record match result error:', error);
    res.status(500).json({
      success: false,
      message: 'Error recording match result',
      error: error.message
    });
  }
};

// Helper function to update team statistics
async function updateTeamStats(groupId, teamName, teamScore, opponentScore, updatedBy) {
  let team = await Leaderboard.findOne({ group: groupId, teamName });

  if (!team) {
    return null;
  }

  team.matchesPlayed += 1;

  if (teamScore > opponentScore) {
    team.matchesWon += 1;
    team.points += 3;
  } else if (teamScore < opponentScore) {
    team.matchesLost += 1;
  } else {
    team.matchesDraw += 1;
    team.points += 1;
  }

  team.goalsFor += teamScore;
  team.goalsAgainst += opponentScore;
  team.updatedBy = updatedBy;

  await team.save();
  return team;
}

// @desc    Manually update team statistics
// @route   PUT /api/leaderboard/:id
// @access  Private (Court Manager only)
exports.updateTeamStats = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = { ...req.body };
    
    updateData.updatedBy = req.user.id;

    const leaderboard = await Leaderboard.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    ).populate('group', 'name');

    if (!leaderboard) {
      return res.status(404).json({
        success: false,
        message: 'Leaderboard entry not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Team statistics updated successfully',
      data: leaderboard
    });
  } catch (error) {
    console.error('Update team stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating team statistics',
      error: error.message
    });
  }
};

// @desc    Delete a team from leaderboard
// @route   DELETE /api/leaderboard/:id
// @access  Private (Court Manager only)
exports.deleteTeam = async (req, res) => {
  try {
    const { id } = req.params;

    const leaderboard = await Leaderboard.findById(id);

    if (!leaderboard) {
      return res.status(404).json({
        success: false,
        message: 'Leaderboard entry not found'
      });
    }

    leaderboard.isActive = false;
    await leaderboard.save();

    res.status(200).json({
      success: true,
      message: 'Team removed from leaderboard',
      data: {}
    });
  } catch (error) {
    console.error('Delete team error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting team',
      error: error.message
    });
  }
};

// @desc    Get all match results for a group
// @route   GET /api/leaderboard/matches/:groupId
// @access  Public
exports.getMatchResults = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { sport, limit = 20 } = req.query;

    const query = { group: groupId };
    if (sport) {
      query.sport = sport;
    }

    const matches = await MatchResult.find(query)
      .populate('group', 'name')
      .populate('recordedBy', 'name email')
      .sort({ matchDate: -1 })
      .limit(parseInt(limit))
      .lean();

    res.status(200).json({
      success: true,
      count: matches.length,
      data: matches
    });
  } catch (error) {
    console.error('Get match results error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching match results',
      error: error.message
    });
  }
};

// @desc    Get statistics summary for a group
// @route   GET /api/leaderboard/stats/:groupId
// @access  Public
exports.getGroupStats = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { sport } = req.query;

    const query = { group: groupId };
    if (sport) {
      query.sport = sport;
    }

    const leaderboard = await Leaderboard.find(query);
    const matches = await MatchResult.find(query);

    const stats = {
      totalTeams: leaderboard.length,
      totalMatches: matches.length,
      totalGoals: leaderboard.reduce((sum, team) => sum + team.goalsFor, 0),
      topScorer: leaderboard.sort((a, b) => b.goalsFor - a.goalsFor)[0],
      leader: leaderboard.sort((a, b) => {
        if (b.points !== a.points) return b.points - a.points;
        if (b.goalDifference !== a.goalDifference) return b.goalDifference - a.goalDifference;
        return b.goalsFor - a.goalsFor;
      })[0]
    };

    res.status(200).json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Get group stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching group statistics',
      error: error.message
    });
  }
};