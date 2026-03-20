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
  getGroupStats
} = require('../controllers/leaderboardController');

const { protect } = require('../middleware/authMiddleware');

// Public routes
router.get('/', getAllLeaderboards);
router.get('/:groupId', getLeaderboard);
router.get('/matches/:groupId', getMatchResults);
router.get('/stats/:groupId', getGroupStats);

// Protected routes (Court Manager only)
// Note: Add role check middleware if you have it in your project
router.post('/initialize', protect, initializeLeaderboard);
router.post('/match-result', protect, recordMatchResult);
router.put('/:id', protect, updateTeamStats);
router.delete('/:id', protect, deleteTeam);

module.exports = router;
