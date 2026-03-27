const express = require('express');
const router = express.Router();
const { createMatch, getMatches, getOpponents, updateMatch, requestJoin, approvePlayer, rejectPlayer } = require('../controllers/matchController');
const {
  validateCreateMatch,
  validateUpdateMatch,
  validateRequestJoin,
  validateApproveRejectPlayer,
  handleValidationErrors
} = require('../middleware/validate');

router.post('/', validateCreateMatch, handleValidationErrors, createMatch);
router.get('/', getMatches);
router.get('/opponents', getOpponents);

router.put('/:id', validateUpdateMatch, handleValidationErrors, updateMatch);
router.post('/:id/request-join', validateRequestJoin, handleValidationErrors, requestJoin);
router.post('/:id/approve', validateApproveRejectPlayer, handleValidationErrors, approvePlayer);
router.post('/:id/reject', validateApproveRejectPlayer, handleValidationErrors, rejectPlayer);

module.exports = router;