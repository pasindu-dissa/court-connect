const express = require('express');
const router = express.Router();
const HealthData = require('../models/healthData');

// ---------------------------------------------------------------------------
// Helper: parse a date string to midnight UTC
// ---------------------------------------------------------------------------
function toMidnightUTC(dateStr) {
  const d = dateStr ? new Date(dateStr) : new Date();
  d.setUTCHours(0, 0, 0, 0);
  return d;
}


module.exports = router;