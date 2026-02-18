const express = require('express');
const router = express.Router();
const { createBooking, getCourtBookings } = require('../controllers/bookingController');

router.post('/', createBooking);
router.get('/:courtId', getCourtBookings);

module.exports = router;