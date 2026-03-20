const express = require('express');
const router = express.Router();
const { createBooking, getCourtBookings, getUserBookings } = require('../controllers/bookingController');

router.post('/', createBooking);
router.get('/user/:userId', getUserBookings);
router.get('/:courtId', getCourtBookings);

module.exports = router;