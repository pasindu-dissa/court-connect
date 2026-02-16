const Booking = require('../models/Booking');
const Court = require('../models/Court');

exports.getCourts = async (req, res) => {
  try {
    const courts = await Court.find({});
    res.json(courts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createBooking = async (req, res) => {
  try {
    const { courtId, startTime, endTime } = req.body;
    const court = await Court.findById(courtId);
    if (!court) return res.status(404).json({ message: 'Court not found' });

    const overlap = await Booking.findOne({
      court: courtId,
      status: 'confirmed',
      startTime: { $lt: new Date(endTime) },
      endTime: { $gt: new Date(startTime) }
    });

    if (overlap) return res.status(400).json({ message: 'Slot already booked' });

    const booking = await Booking.create({
      court: courtId,
      user: req.user._id,
      startTime,
      endTime,
      totalPrice: court.price
    });
    res.status(201).json(booking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getUserBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.params.userId }).populate('court');
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};