const mongoose = require('mongoose');
const Leaderboard = require('../models/Leaderboard');
const LeaderboardEntry = require('../models/LeaderboardEntry');
const MatchResult = require('../models/MatchResults');
const Group = require('../models/Group');
const User = require('../models/User');

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

// @desc    Award a point to a user for a specific sport and court
// @route   POST /api/leaderboards/award-point
// @access  Private (Court Manager only)
exports.awardPoint = async (req, res) => {
  try {
    const { userId, courtId, sportType } = req.body;

    if (!userId || !courtId || !sportType) {
      return res.status(400).json({
        success: false,
        message: 'Please provide userId, courtId, and sportType'
      });
    }

    // Role check (assuming basic auth populates req.user.role)
    // if (req.user.role !== 'court_owner' && req.user.role !== 'admin') {
    //  return res.status(403).json({ success: false, message: 'Not authorized' });
    // }

    // Convert courtId string to ObjectId since LeaderboardEntry stores it as ObjectId
    let queryCourtId = courtId;
    if (mongoose.Types.ObjectId.isValid(courtId)) {
      queryCourtId = new mongoose.Types.ObjectId(courtId);
    }

    let entry = await LeaderboardEntry.findOne({ user: userId, courtId: queryCourtId, sportType });

    if (!entry) {
      entry = new LeaderboardEntry({
        user: userId,
        courtId,
        sportType,
        points: 0
      });
    }

    entry.points += 1;
    await entry.save();

    res.status(200).json({
      success: true,
      message: 'Point awarded successfully',
      data: entry
    });
  } catch (error) {
    console.error('Award point error:', error);
    res.status(500).json({
      success: false,
      message: 'Error awarding point',
      error: error.message
    });
  }
};

// @desc    Get top players across specific sport and court
// @route   GET /api/leaderboard/top-players
// @access  Public
exports.getTopPlayers = async (req, res) => {
  try {
    const { sportType, courtId, limit = 10 } = req.query;
    
    const matchStage = {};
    if (sportType && sportType !== 'all') matchStage.sportType = sportType;
    if (courtId && courtId !== 'all') {
      try {
        matchStage.courtId = new mongoose.Types.ObjectId(courtId);
      } catch(e) { /* invalid format, ignore or handle */ }
    }

    const pipeline = [
      { $match: matchStage },
      { $sort: { points: -1 } },
      { $limit: parseInt(limit) },
      {
        $lookup: {
          from: 'users',
          localField: 'user',
          foreignField: '_id',
          as: 'userDetails'
        }
      },
      { $unwind: '$userDetails' },
      {
        $project: {
          _id: 1,
          points: 1,
          sportType: 1,
          courtId: 1,
          user: {
            _id: '$userDetails._id',
            name: '$userDetails.name',
            profileImage: '$userDetails.profileImage',
            weeklyStreak: '$userDetails.weeklyStreak',
            stats: '$userDetails.stats'
          }
        }
      }
    ];

    const topPlayers = await LeaderboardEntry.aggregate(pipeline);

    res.status(200).json({
      success: true,
      data: topPlayers // Changed from 'rankedPlayers' to 'topPlayers' to match variable name
    });

  } catch (error) {
    console.error('Get top players error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching top players',
      error: error.message
    });
  }
};

// @desc    Get current user's stats on leaderboard
// @route   GET /api/leaderboard/my-stats
// @access  Private
exports.getUserStats = async (req, res) => {
  try {
    const { sportType, courtId } = req.query;
    // Depending on auth implementation, req.user could have _id, id, or uid.
    const userId = req.user._id || req.user.id || req.user.firebaseUid;

    // 1. Get user streak
    let user;
    if (mongoose.Types.ObjectId.isValid(userId)) {
      user = await User.findById(userId).select('weeklyStreak firebaseUid');
    } else {
      user = await User.findOne({ firebaseUid: userId }).select('weeklyStreak firebaseUid');
    }
    const realUserId = user ? user._id : userId;
    const streak = user?.weeklyStreak?.current || 0;

    // 2. Build match query
    let matchQuery = {};
    if (sportType && sportType !== 'all') matchQuery.sportType = sportType;
    if (courtId && courtId !== 'all') {
       if (mongoose.Types.ObjectId.isValid(courtId)) {
           matchQuery.courtId = new mongoose.Types.ObjectId(courtId);
       } else {
           // Provide fallback string matching if courtId is not valid ObjectId
           matchQuery.courtId = courtId; 
       }
    }

    // 3. User's specific score in this category
    const userScoreAgg = await LeaderboardEntry.aggregate([
      { $match: { ...matchQuery, user: new mongoose.Types.ObjectId(realUserId) } },
      { $group: { _id: null, totalPoints: { $sum: "$points" } } }
    ]);
    const score = userScoreAgg.length > 0 ? userScoreAgg[0].totalPoints : 0;

    // 4. Determine user's Rank
    const allScoresAgg = await LeaderboardEntry.aggregate([
      { $match: matchQuery },
      { $group: { _id: "$user", totalPoints: { $sum: "$points" } } },
      { $sort: { totalPoints: -1 } }
    ]);
    
    const rankIndex = allScoresAgg.findIndex(s => s._id.toString() === realUserId.toString());
    const rank = rankIndex !== -1 ? rankIndex + 1 : '-';

    res.status(200).json({
      success: true,
      data: {
        rank,
        score,
        streak
      }
    });
  } catch (error) {
    console.error('getUserStats error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching user stats',
      error: error.message
    });
  }
};