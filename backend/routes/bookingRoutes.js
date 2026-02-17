const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');

// TEMP auth mock
router.use((req, res, next) => {
  req.user = { id: '64f000000000000000000001' };
  next();
});

router.post('/', bookingController.createBooking);
router.post('/join/:id', bookingController.joinBooking);
router.get('/', bookingController.getBookings);

module.exports = router;
