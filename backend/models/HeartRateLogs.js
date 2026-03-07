// backend/models/HeartRateLogs.js

const mongoose = require('mongoose');

const heartRateLogSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: [true, 'User ID is required'],
      index: true,
    },
    // Array of readings uploaded in one batch
    readings: [
      {
        bpm: {
          type: Number,
          required: true,
          min: 30,
          max: 250,
        },
        recordedAt: {
          type: Date,
          required: true,
        },
      },
    ],
    // Date of this log (day-level granularity for easy querying)
    logDate: {
      type: Date,
      required: true,
      default: () => {
        const now = new Date();
        return new Date(now.getFullYear(), now.getMonth(), now.getDate());
      },
    },
    // Computed stats stored for quick retrieval
    stats: {
      average: { type: Number, default: 0 },
      max: { type: Number, default: 0 },
      resting: { type: Number, default: 0 },
      count: { type: Number, default: 0 },
    },
  },
  {
    timestamps: true,
  }
);

// Index to prevent duplicate logs for same user on same day
heartRateLogSchema.index({ userId: 1, logDate: 1 }, { unique: true });

// Pre-save hook to compute stats automatically
heartRateLogSchema.pre('save', function (next) {
  if (this.readings && this.readings.length > 0) {
    const bpms = this.readings.map((r) => r.bpm).sort((a, b) => a - b);
    const sum = bpms.reduce((a, b) => a + b, 0);
    const restingCount = Math.max(1, Math.ceil(bpms.length * 0.1));

    this.stats = {
      average: Math.round(sum / bpms.length),
      max: bpms[bpms.length - 1],
      resting: Math.round(
        bpms.slice(0, restingCount).reduce((a, b) => a + b, 0) / restingCount
      ),
      count: bpms.length,
    };
  }
  next();
});

const HeartRateLogs = mongoose.model('HeartRateLogs', heartRateLogSchema);

module.exports = HeartRateLogs;