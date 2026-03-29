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
const {
  validateInitLeaderboard,
  validateRecordMatchResult,
  validateAwardPoint,
  validateUpdateTeamStats,
  handleValidationErrors
} = require('../middleware/validate');

// Public routes
router.get('/', getAllLeaderboards);
// FEATURE: Global / Filtered Top Players Leaderboard
// Retrieves all players scored based on points, allowing for sport/court filters.
router.get('/top-players', getTopPlayers);
router.get('/:groupId', getLeaderboard);
router.get('/matches/:groupId', getMatchResults);
router.get('/stats/:groupId', getGroupStats);

// Protected routes (Logged in users)
// FEATURE: Personal Gamification Stats
// Retrieves the authenticated user's current rank, total score, and active week streak.
router.get('/my-stats', protect, getUserStats);

// Private routes (Court Manager only)
// FEATURE: Court Admin Scoring
// Allows court owners or admins to initialize tournaments and record match results.
router.post('/initialize', protect, validateInitLeaderboard, handleValidationErrors, initializeLeaderboard);
router.post('/match-result', protect, validateRecordMatchResult, handleValidationErrors, recordMatchResult);
router.post('/award-point', protect, validateAwardPoint, handleValidationErrors, awardPoint);
router.put('/:id', protect, validateUpdateTeamStats, handleValidationErrors, updateTeamStats);
router.delete('/:id', protect, deleteTeam);

module.exports = router;
