const mongoose = require('mongoose');

const healthDataSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    date: {
      type: Date,
      required: true,
      default: () => new Date().setHours(0, 0, 0, 0),
    },

    // Play / activity
    playTimeMinutes: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Calories
    caloriesBurned: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Courts
    courtsVisited: {
      type: Number,
      default: 0,
      min: 0,
    },

    // Heart rate (beats per minute)
    heartRate: {
      average: { type: Number, default: 0 },
      max:     { type: Number, default: 0 },
      resting: { type: Number, default: 0 },
    },

    // Daily goal targets
    goals: {
      activityMinutes: { type: Number, default: 60 },
      caloriesTarget:  { type: Number, default: 500 },
    },

    // Source of the data
    source: {
      type: String,
      enum: ['google_fit', 'health_connect', 'manual', 'mock'],
      default: 'manual',
    },
  },
  {
    timestamps: true,
  }
);

// Compound index: one record per user per day
healthDataSchema.index({ userId: 1, date: 1 }, { unique: true });

// Virtual: activity goal completion percentage
healthDataSchema.virtual('activityGoalPercent').get(function () {
  if (!this.goals.activityMinutes) return 0;
  return Math.min(
    100,
    Math.round((this.playTimeMinutes / this.goals.activityMinutes) * 100)
  );
});

// Virtual: calorie goal completion percentage
healthDataSchema.virtual('caloriesGoalPercent').get(function () {
  if (!this.goals.caloriesTarget) return 0;
  return Math.min(
    100,
    Math.round((this.caloriesBurned / this.goals.caloriesTarget) * 100)
  );
});

healthDataSchema.set('toJSON', { virtuals: true });
healthDataSchema.set('toObject', { virtuals: true });

const HealthData = mongoose.model('HealthData', healthDataSchema);

module.exports = HealthData;