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
router.post('/', async (req, res) => {
  try {
    const {
      userId,
      playTimeMinutes,
      caloriesBurned,
      courtsVisited,
      heartRate,
      goals,
      source,
      date,
    } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'userId is required' });
    }

    const recordDate = toMidnightUTC(date);

    // Upsert: find the record for this user+date and update it, or create it
    const updated = await HealthData.findOneAndUpdate(
      { userId, date: recordDate },
      {
        $set: {
          ...(playTimeMinutes !== undefined && { playTimeMinutes }),
          ...(caloriesBurned  !== undefined && { caloriesBurned }),
          ...(courtsVisited   !== undefined && { courtsVisited }),
          ...(heartRate       !== undefined && { heartRate }),
          ...(goals           !== undefined && { goals }),
          ...(source          !== undefined && { source }),
        },
      },
      { new: true, upsert: true, runValidators: true, setDefaultsOnInsert: true }
    );

    return res.status(200).json({ success: true, data: updated });
  } catch (err) {
    console.error('[POST /health]', err);
    return res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});
router.get('/summary', async (req, res) => {
  try {
    const { userId, date } = req.query;

    if (!userId) {
      return res.status(400).json({ error: 'userId query param is required' });
    }

    const record = await HealthData.findOne({
      userId,
      date: toMidnightUTC(date),
    }).lean({ virtuals: true });

    if (!record) {
      return res.status(404).json({ error: 'No health record found for this date' });
    }

    const summary = {
      date:            record.date,
      playTimeMinutes: record.playTimeMinutes,
      caloriesBurned:  record.caloriesBurned,
      courtsVisited:   record.courtsVisited,
      heartRate:       record.heartRate,
      goals:           record.goals,
      activityGoalPct: record.activityGoalPercent,
      caloriesGoalPct: record.caloriesGoalPercent,
      source:          record.source,
      lastUpdated:     record.updatedAt,
    };

    return res.status(200).json({ success: true, data: summary });
  } catch (err) {
    console.error('[GET /health/summary]', err);
    return res.status(500).json({ error: 'Internal server error', details: err.message });
  }
});


module.exports = router;