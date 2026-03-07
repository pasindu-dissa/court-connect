// backend/routes/heartRateRoutes.js

const express = require('express');
const router = express.Router();
const { batchUploadHeartRate, getHeartRateLog } = require('../controllers/heartRateController');

// POST /api/health/heartrate/batch  → Upload batch of readings
router.post('/heartrate/batch', batchUploadHeartRate);

// GET  /api/health/heartrate/:userId?date=YYYY-MM-DD → Get a day's log
router.get('/heartrate/:userId', getHeartRateLog);

module.exports = router;