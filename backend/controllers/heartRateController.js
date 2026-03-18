// backend/controllers/heartRateController.js

const HeartRateLogs = require('../models/HeartRateLogs');

// @desc    Batch upload heart rate readings for a user (one day)
// @route   POST /api/health/heartrate/batch
// @access  Private (requires auth token)
const batchUploadHeartRate = async (req, res) => {
  const { userId, readings, logDate } = req.body;

  if (!userId || !readings || !Array.isArray(readings) || readings.length === 0) {
    return res.status(400).json({ message: 'userId and non-empty readings array are required.' });
  }

  try {
    // Parse logDate or default to today
    const date = logDate ? new Date(logDate) : new Date();
    const dayOnly = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    // Upsert: update existing log for today or create new one
    const log = await HeartRateLogs.findOneAndUpdate(
      { userId, logDate: dayOnly },
      {
        $push: { readings: { $each: readings } },
        $setOnInsert: { userId, logDate: dayOnly },
      },
      { new: true, upsert: true, runValidators: true }
    );

    // Manually trigger pre-save stats calculation
    await log.save();

    res.status(200).json({
      message: 'Heart rate logs uploaded successfully.',
      stats: log.stats,
      totalReadings: log.readings.length,
    });
  } catch (error) {
    console.error('batchUploadHeartRate error:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Get heart rate log for a user on a specific date
// @route   GET /api/health/heartrate/:userId?date=YYYY-MM-DD
// @access  Private
const getHeartRateLog = async (req, res) => {
  const { userId } = req.params;
  const { date } = req.query;

  try {
    const queryDate = date ? new Date(date) : new Date();
    const dayOnly = new Date(queryDate.getFullYear(), queryDate.getMonth(), queryDate.getDate());

    const log = await HeartRateLogs.findOne({ userId, logDate: dayOnly });

    if (!log) {
      return res.status(404).json({ message: 'No heart rate log found for this date.' });
    }

    res.status(200).json(log);
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

module.exports = { batchUploadHeartRate, getHeartRateLog };