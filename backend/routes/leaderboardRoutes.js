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

const { authMiddleware } = require('../middleware/authMiddleware');

// Public routes
router.get('/', getAllLeaderboards);
router.get('/:groupId', getLeaderboard);
router.get('/matches/:groupId', getMatchResults);
router.get('/stats/:groupId', getGroupStats);

// Protected routes (Court Manager only)
// Note: Add role check middleware if you have it in your project
router.post('/initialize', authMiddleware, initializeLeaderboard);
router.post('/match-result', authMiddleware, recordMatchResult);
router.put('/:id', authMiddleware, updateTeamStats);
router.delete('/:id', authMiddleware, deleteTeam);

module.exports = router;
