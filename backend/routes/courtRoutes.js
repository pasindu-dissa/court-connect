const express = require('express');
const router = express.Router();
const courtController = require('../controllers/courtController');

router.post('/', courtController.createCourt);
router.get('/', courtController.getCourts);
router.get('/nearby', courtController.findNearbyCourts);

module.exports = router;
