const express = require('express');
const router = express.Router();

// <-- NEW: Update the imports to include the 3 new functions
const { 
  addCourt, 
  getOwnerCourts, 
  getAllCourts,
  getDashboardStats,
  getOwnerBookings,
  getOwnerRevenue
} = require('../controllers/courtController'); 

router.post('/', addCourt);
router.get('/', getAllCourts);
router.get('/owner/:ownerId', getOwnerCourts);

// <-- NEW: Add the 3 new routes below
router.get('/owner/:ownerId/stats', getDashboardStats);
router.get('/owner/:ownerId/bookings', getOwnerBookings);
router.get('/owner/:ownerId/revenue', getOwnerRevenue);

module.exports = router;