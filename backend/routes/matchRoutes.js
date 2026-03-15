const express = require('express');
const router = express.Router();
const { createMatch, getMatches, getOpponents, updateMatch, requestJoin, approvePlayer, rejectPlayer } = require('../controllers/matchController');

router.post('/', createMatch);
router.get('/', getMatches);
router.get('/opponents', getOpponents);

router.put('/:id', updateMatch); 
router.post('/:id/request-join', requestJoin); 
router.post('/:id/approve', approvePlayer); 
router.post('/:id/reject', rejectPlayer); 

module.exports = router;