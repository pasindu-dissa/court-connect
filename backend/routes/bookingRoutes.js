const express = require('express');
const router = express.Router();
const { createBooking, getCourtBookings, getUserBookings } = require('../controllers/bookingController');
const { validateCreateBooking, handleValidationErrors } = require('../middleware/validate');

router.post('/', validateCreateBooking, handleValidationErrors, createBooking);
router.get('/user/:userId', getUserBookings);
router.get('/:courtId', getCourtBookings);

module.exports = router;