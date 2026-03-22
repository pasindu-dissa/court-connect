const Court = require('../models/court');
const Booking = require('../models/booking'); // <-- FIX: Use lowercase to match filename


// @desc    Add a new court
// @route   POST /api/courts
const addCourt = async (req, res) => {
  try {
    const { 
      ownerId, name, location, district, sports, // Changed to sports
      pricePerHour, description, images, contactNumber,
      latitude, longitude, plusCode, googleMapsLink 
    } = req.body;

    const court = await Court.create({
      ownerId,
      name,
      location,
      district,
      sports, 
      pricePerHour,
      description,
      images,
      contactNumber,
      latitude,
      longitude,
      plusCode,
      googleMapsLink
    });

    res.status(201).json(court);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Get courts belonging to a specific owner
const getOwnerCourts = async (req, res) => {
  try {
    const courts = await Court.find({ ownerId: req.params.ownerId });
    res.json(courts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get all courts (For players)
const getAllCourts = async (req, res) => {
  try {
    const courts = await Court.find({ isOpen: true });
    res.json(courts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get Quick Dashboard Stats (Today's Bookings & Monthly Revenue)
// @route   GET /api/courts/owner/:ownerId/stats
const getDashboardStats = async (req, res) => {
  try {
    const ownerId = req.params.ownerId;
    
    // 1. Find all courts owned by this user
    const courts = await Court.find({ ownerId });
    const courtIds = courts.map(c => c._id);

    // 2. Setup date strings for comparison (YYYY-MM-DD and YYYY-MM)
    const now = new Date();
    const todayStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
    const currentMonthStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;

    // 3. Get all confirmed bookings for these courts
    const bookings = await Booking.find({ 
      courtId: { $in: courtIds },
      status: 'Confirmed'
    });

    let todaysBookings = 0;
    let monthlyRevenue = 0;

    // 4. Calculate stats
    bookings.forEach(b => {
      if (b.date === todayStr) {
        todaysBookings++;
      }
      if (b.date && b.date.startsWith(currentMonthStr)) {
        monthlyRevenue += (b.totalPrice || 0);
      }
    });

    res.json({ todaysBookings, monthlyRevenue });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get all bookings for courts owned by a specific owner
// @route   GET /api/courts/owner/:ownerId/bookings
const getOwnerBookings = async (req, res) => {
  try {
    const ownerId = req.params.ownerId;
    const courts = await Court.find({ ownerId });
    const courtIds = courts.map(c => c._id);
    
    // Map court names for easy O(1) lookup
    const courtMap = {};
    courts.forEach(c => { courtMap[c._id.toString()] = c.name; });

    // Find bookings and populate the user details
    const bookings = await Booking.find({ courtId: { $in: courtIds } })
      .populate('userId', 'name')
      .sort({ date: -1, startTime: -1 }); // Newest first

    // Format for the Flutter frontend
    const formattedBookings = bookings.map(b => ({
      id: b._id,
      courtName: courtMap[b.courtId.toString()] || 'Unknown Court',
      playerName: b.userId ? b.userId.name : 'Unknown Player',
      date: b.date,
      time: b.startTime,
      status: b.status,
      totalPrice: b.totalPrice
    }));

    res.json(formattedBookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get detailed revenue breakdown by court
// @route   GET /api/courts/owner/:ownerId/revenue
const getOwnerRevenue = async (req, res) => {
  try {
    const ownerId = req.params.ownerId;
    const courts = await Court.find({ ownerId });
    const courtIds = courts.map(c => c._id);
    
    const courtMap = {};
    courts.forEach(c => { courtMap[c._id.toString()] = c.name; });

    const bookings = await Booking.find({ 
      courtId: { $in: courtIds },
      status: 'Confirmed'
    });

    let totalRevenue = 0;
    const breakdownMap = {};

    // Group revenue by court
    bookings.forEach(b => {
      const rev = b.totalPrice || 0;
      totalRevenue += rev;
      
      const cId = b.courtId.toString();
      if (!breakdownMap[cId]) {
        breakdownMap[cId] = {
          courtName: courtMap[cId] || 'Unknown Court',
          revenue: 0
        };
      }
      breakdownMap[cId].revenue += rev;
    });

    // Convert map to array and sort by highest revenue
    const breakdown = Object.values(breakdownMap).sort((a, b) => b.revenue - a.revenue);

    res.json({ totalRevenue, breakdown });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Update the exports at the very bottom!
module.exports = { 
  addCourt, 
  getOwnerCourts, 
  getAllCourts, 
  getDashboardStats, 
  getOwnerBookings, 
  getOwnerRevenue 
};