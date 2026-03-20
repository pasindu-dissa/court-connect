const mongoose = require('mongoose');

const bookingSchema = mongoose.Schema(
  {
    courtId: { type: mongoose.Schema.Types.ObjectId, ref: 'Court', required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    date: { type: String, required: true }, // Format: "YYYY-MM-DD"
    startTime: { type: String, required: true }, // e.g. "10:00 AM"
    duration: { type: Number, default: 1 }, // Hours
    totalPrice: { type: Number, required: true },
    status: { type: String, enum: ['Confirmed', 'Cancelled'], default: 'Confirmed' }
  },
  { timestamps: true }
);

// CRITICAL FIX: Check if the model already exists before compiling it to prevent OverwriteModelError
module.exports = mongoose.models.Booking || mongoose.model('Booking', bookingSchema);