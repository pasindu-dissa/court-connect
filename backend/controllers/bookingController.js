const Booking = require('../models/booking');
const Court = require('../models/court');
const User = require('../models/User');
const { pushNotificationToUser } = require('../services/notificationService');

// @desc    Create a new booking
// @route   POST /api/bookings
const createBooking = async (req, res) => {
  try {
    const { courtId, userId, date, startTime, totalPrice } = req.body;

    // Check if slot is already taken
    const existing = await Booking.findOne({ courtId, date, startTime, status: 'Confirmed' });
    if (existing) {
      return res.status(400).json({ message: 'Slot already booked' });
    }

    const booking = await Booking.create({
      courtId,
      userId,
      date,
      startTime,
      totalPrice
    });

    // Notify the player
    await pushNotificationToUser(
      userId,
      'Booking confirmed ✅',
      `Your booking for ${date} at ${startTime} is confirmed.`,
      { type: 'booking' }
    );

    // Notify court owner
    const court = await Court.findById(courtId);
    if (court?.ownerId) {
      await pushNotificationToUser(
        court.ownerId,
        'New booking received 📅',
        `A new booking was made for ${date} at ${startTime}.`,
        { type: 'booking' }
      );
    }

    // Weekly Streak Logic
    const bookedUser = await User.findById(userId);
    if (bookedUser) {
      const now = new Date();
      const dayOfWeek = now.getUTCDay(); // 0 is Sunday
      const diffToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; 
      const currentWeekStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - diffToMonday));

      if (!bookedUser.weeklyStreak || !bookedUser.weeklyStreak.lastBookingWeekStart) {
        bookedUser.weeklyStreak = { current: 1, lastBookingWeekStart: currentWeekStart };
      } else {
        const lastStart = new Date(bookedUser.weeklyStreak.lastBookingWeekStart);
        const timeDiff = currentWeekStart.getTime() - lastStart.getTime();
        const weeksDiff = Math.round(timeDiff / (1000 * 3600 * 24 * 7));

        if (weeksDiff === 1) {
          bookedUser.weeklyStreak.current += 1;
          bookedUser.weeklyStreak.lastBookingWeekStart = currentWeekStart;
        } else if (weeksDiff > 1) {
          bookedUser.weeklyStreak.current = 1;
          bookedUser.weeklyStreak.lastBookingWeekStart = currentWeekStart;
        }
      }
      await bookedUser.save();
    }

    res.status(201).json(booking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Get bookings for a specific court and date
// @route   GET /api/bookings/:courtId
const getCourtBookings = async (req, res) => {
  try {
    const { date } = req.query; // ?date=YYYY-MM-DD
    const query = { courtId: req.params.courtId, status: 'Confirmed' };
    if (date) query.date = date;

    const bookings = await Booking.find(query).select('startTime');
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getUserBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({
      userId: req.params.userId,
      status: 'Confirmed',
      date: { $gte: new Date().toISOString().split('T')[0] }
    })
      .populate('courtId', 'name location images sports')
      .sort({ date: 1, startTime: 1 });

    res.json({
      success: true,
      count: bookings.length,
      data: bookings
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { createBooking, getCourtBookings, getUserBookings };