const express = require('express');
const router = express.Router();

const { 
  addCourt, 
  getOwnerCourts, 
  getAllCourts,
  getDashboardStats,
  getOwnerBookings,
  getOwnerRevenue
} = require('../controllers/courtController');
const { validateAddCourt, handleValidationErrors } = require('../middleware/validate');

router.post('/', validateAddCourt, handleValidationErrors, addCourt);
router.get('/', getAllCourts);
router.get('/owner/:ownerId', getOwnerCourts);

router.get('/owner/:ownerId/stats', getDashboardStats);
router.get('/owner/:ownerId/bookings', getOwnerBookings);
router.get('/owner/:ownerId/revenue', getOwnerRevenue);

module.exports = router;