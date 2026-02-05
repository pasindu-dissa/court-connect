const Booking = require('../models/Booking');
const Court = require('../models/Court');

exports.createBooking = async (req, res) => {
  try {
    const { court, date, startTime, endTime, sport } = req.body;

    const courtData = await Court.findById(court);
    if (!courtData) {
      return res.status(404).json({ success: false, message: 'Court not found' });
    }

    const available = await Booking.isAvailable(
      court,
      date,
      startTime,
      endTime
    );

    if (!available) {
      return res.status(400).json({ success: false, message: 'Time slot unavailable' });
    }

    const duration =
      (parseInt(endTime.split(':')[0]) * 60 + parseInt(endTime.split(':')[1])) -
      (parseInt(startTime.split(':')[0]) * 60 + parseInt(startTime.split(':')[1]));

    const totalCost = (courtData.pricePerHour / 60) * duration;

    const booking = await Booking.create({
      court,
      user: req.user.id,
      players: [req.user.id],
      sport,
      date,
      startTime,
      endTime,
      duration,
      totalCost
    });

    res.status(201).json({ success: true, data: booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.joinBooking = async (req, res) => {
  const booking = await Booking.findById(req.params.id);

  if (!booking) {
    return res.status(404).json({ success: false, message: 'Booking not found' });
  }

  if (booking.players.includes(req.user.id)) {
    return res.status(400).json({ success: false, message: 'Already joined' });
  }

  booking.players.push(req.user.id);
  await booking.save();

  res.json({
    success: true,
    players: booking.players.length,
    costPerPerson: (booking.totalCost / booking.players.length).toFixed(2)
  });
};

exports.getBookings = async (req, res) => {
  const bookings = await Booking.find()
    .populate('court', 'name location.city pricePerHour')
    .populate('players', 'fullName');

  res.json({ success: true, data: bookings });
};
