const express = require('express');
const router = express.Router();
const { findOpponents } = require('../controllers/matchmakingController');

// POST http://localhost:5000/api/matchmaking/find
router.post('/find', findOpponents);

module.exports = router;