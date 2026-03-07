const express = require('express');
const router = express.Router();
const { createTeam, joinTeam, getTeamById } = require('../controllers/teamController');
const { protect } = require('../middleware/authMiddleware');

router.post('/', protect, createTeam);
router.put('/join', protect, joinTeam);
router.get('/:id', protect, getTeamById);

module.exports = router;