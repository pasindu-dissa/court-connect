const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  court: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Court',
    required: true
  },

  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },

  players: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],

  sport: String,
  date: Date,
  startTime: String,
  endTime: String,
  duration: Number,
  totalCost: Number,

  status: {
    type: String,
    enum: ['confirmed', 'cancelled'],
    default: 'confirmed'
  },

  createdAt: {
    type: Date,
    default: Date.now
  }
});

/**
 * Availability check
 */
bookingSchema.statics.isAvailable = async function (
  courtId,
  date,
  startTime,
  endTime
) {
  const clash = await this.findOne({
    court: courtId,
    date: new Date(date),
    status: 'confirmed',
    startTime: { $lt: endTime },
    endTime: { $gt: startTime }
  });

  return !clash;
};

module.exports = mongoose.model('Booking', bookingSchema);
