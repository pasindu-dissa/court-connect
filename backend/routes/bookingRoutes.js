const express = require('express');
const router = express.Router();
const { getCourts, createBooking, getUserBookings } = require('../controllers/bookingController');
const { protect } = require('../middleware/authMiddleware');

router.get('/courts', getCourts);
router.post('/', protect, createBooking);
router.get('/user/:userId', protect, getUserBookings);

module.exports = router;