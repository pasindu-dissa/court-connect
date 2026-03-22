const express = require('express');
const router = express.Router();
const {
  getLeaderboard,
  getAllLeaderboards,
  initializeLeaderboard,
  recordMatchResult,
  updateTeamStats,
  deleteTeam,
  getMatchResults,
  getGroupStats,
  awardPoint,
  getTopPlayers,
  getUserStats
} = require('../controllers/leaderboardController');

const { protect } = require('../middleware/authMiddleware');

// Public routes
router.get('/', getAllLeaderboards);
router.get('/top-players', getTopPlayers);
router.get('/:groupId', getLeaderboard);
router.get('/matches/:groupId', getMatchResults);
router.get('/stats/:groupId', getGroupStats);

// Protected routes (Logged in users)
router.get('/my-stats', protect, getUserStats);

// Private routes (Court Manager only)
// Note: Add role check middleware if you have it in your project
router.post('/initialize', protect, initializeLeaderboard);
router.post('/match-result', protect, recordMatchResult);
router.post('/award-point', protect, awardPoint);
router.put('/:id', protect, updateTeamStats);
router.delete('/:id', protect, deleteTeam);

module.exports = router;
