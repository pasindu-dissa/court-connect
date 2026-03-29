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
router.get('/top-players', getTopPlayers);
router.get('/:groupId', getLeaderboard);
router.get('/matches/:groupId', getMatchResults);
router.get('/stats/:groupId', getGroupStats);

// Protected routes (Logged in users)
router.get('/my-stats', protect, getUserStats);

// Private routes (Court Manager only)
router.post('/initialize', protect, validateInitLeaderboard, handleValidationErrors, initializeLeaderboard);
router.post('/match-result', protect, validateRecordMatchResult, handleValidationErrors, recordMatchResult);
router.post('/award-point', protect, validateAwardPoint, handleValidationErrors, awardPoint);
router.put('/:id', protect, validateUpdateTeamStats, handleValidationErrors, updateTeamStats);
router.delete('/:id', protect, deleteTeam);

module.exports = router;
