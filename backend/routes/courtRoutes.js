const express = require('express');
const router = express.Router();
const { addCourt, getOwnerCourts, getAllCourts } = require('../controllers/courtController');

router.post('/', addCourt);
router.get('/', getAllCourts);
router.get('/owner/:ownerId', getOwnerCourts);

module.exports = router;