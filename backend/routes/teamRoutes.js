const express = require('express');
const router = express.Router();
const { createTeam, joinTeam, getTeamById } = require('../controllers/teamController');
const { protect } = require('../middleware/authMiddleware');
const { validateCreateTeam, validateJoinTeam, handleValidationErrors } = require('../middleware/validate');

router.post('/', protect, validateCreateTeam, handleValidationErrors, createTeam);
router.put('/join', protect, validateJoinTeam, handleValidationErrors, joinTeam);
router.get('/:id', protect, getTeamById);

module.exports = router;