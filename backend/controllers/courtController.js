const Court = require('../models/court');

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

module.exports = { addCourt, getOwnerCourts, getAllCourts };