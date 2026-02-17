const Court = require('../models/court');

// @desc    Add a new court
// @route   POST /api/courts
const addCourt = async (req, res) => {
  try {
    // 1. Destructure all fields including new location data
    const { 
      ownerId, name, location, district, sport, 
      pricePerHour, description, images, contactNumber,
      latitude, longitude, googleMapsLink 
    } = req.body;

    const court = await Court.create({
      ownerId,
      name,
      location,
      district,
      sport,
      pricePerHour,
      description,
      images,
      contactNumber,
      latitude,
      longitude,
      googleMapsLink
    });

    res.status(201).json(court);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// @desc    Get courts belonging to a specific owner
// @route   GET /api/courts/owner/:ownerId
const getOwnerCourts = async (req, res) => {
  try {
    const courts = await Court.find({ ownerId: req.params.ownerId });
    res.json(courts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get all courts (For players)
// @route   GET /api/courts
const getAllCourts = async (req, res) => {
  try {
    const courts = await Court.find({ isOpen: true });
    res.json(courts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { addCourt, getOwnerCourts, getAllCourts };