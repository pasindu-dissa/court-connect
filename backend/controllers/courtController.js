const Court = require('../models/Court');

/**
 * Create court
 */
exports.createCourt = async (req, res) => {
  try {
    const court = await Court.create(req.body);
    res.status(201).json({ success: true, data: court });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Get all courts
 */
exports.getCourts = async (req, res) => {
  const courts = await Court.find();
  res.json({ success: true, data: courts });
};

/**
 * Find courts within distance (km)
 */
exports.findNearbyCourts = async (req, res) => {
  const { lng, lat, distance } = req.query;

  const courts = await Court.find({
    'location.coordinates': {
      $nearSphere: {
        $geometry: {
          type: 'Point',
          coordinates: [parseFloat(lng), parseFloat(lat)]
        },
        $maxDistance: distance * 1000
      }
    }
  });

  res.json({ success: true, data: courts });
};
