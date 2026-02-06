const User = require('../models/User');

// @desc    Update User Skills & Preferences
// @route   PUT /api/users/profile
// @access  Public (Make this Private later with Auth)
const updateUserProfile = async (req, res) => {
  const { userId, location, skills, availability } = req.body;

  try {
    // 1. Find the user (In real app, get ID from Token)
    const user = await User.findById(userId);

    if (user) {
      // 2. Update fields
      user.location = location || user.location;
      user.skills = skills || user.skills;
      user.availability = availability || user.availability;

      // 3. Save to DB
      const updatedUser = await user.save();

      res.json({
        _id: updatedUser._id,
        name: updatedUser.name,
        skills: updatedUser.skills,
        availability: updatedUser.availability,
      });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Register a new user (Basic)
// @route   POST /api/users
const registerUser = async (req, res) => {
    const { name, email, password } = req.body;
    try {
        const userExists = await User.findOne({ email });
        if (userExists) return res.status(400).json({ message: 'User already exists' });

        const user = await User.create({ name, email, password });
        if (user) {
            res.status(201).json({ _id: user._id, name: user.name, email: user.email });
        } else {
            res.status(400).json({ message: 'Invalid user data' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

module.exports = { updateUserProfile, registerUser };