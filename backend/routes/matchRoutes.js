const express = require('express');
const router = express.Router();
const { getMatches, createMatch } = require('../controllers/matchController');

router.get('/', getMatches);
router.post('/', createMatch);

module.exports = router;