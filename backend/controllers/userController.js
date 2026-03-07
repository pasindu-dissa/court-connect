const User = require('../models/User');

// @desc    Register a new user
// @route   POST /api/users
const registerUser = async (req, res) => {
    // 1. Destructure ALL fields, including firebaseUid
    const { 
        firebaseUid, // <--- CRITICAL: Make sure this is here
        name, 
        email, 
        password, 
        age, 
        district, 
        city, 
        location 
    } = req.body;

    try {
        // 2. Check if user exists (by email OR firebaseUid)
        const userExists = await User.findOne({ $or: [{ email }, { firebaseUid }] });
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        // 3. Create User with ALL fields
        const user = await User.create({
            firebaseUid, // <--- Pass it to create
            name,
            email,
            password, // In hybrid auth, this might be a placeholder hash
            age,
            district,
            city,
            location
        });

        if (user) {
            res.status(201).json({
                _id: user._id,
                firebaseUid: user.firebaseUid,
                name: user.name,
                email: user.email,
                role: user.role
            });
        } else {
            res.status(400).json({ message: 'Invalid user data' });
        }
    } catch (error) {
        console.error("Register Error:", error); // Log for debugging
        res.status(500).json({ message: error.message });
    }
}

// ... keep updateUserProfile and getUserByEmail as they were ...
const updateUserProfile = async (req, res) => {
  const { userId, location, skills, availability } = req.body;
  try {
    const user = await User.findById(userId);
    if (user) {
      user.location = location || user.location;
      user.skills = skills || user.skills;
      user.availability = availability || user.availability;
      const updatedUser = await user.save();
      res.json(updatedUser);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getUserByEmail = async (req, res) => {
  const { email } = req.query;
  try {
      const user = await User.findOne({ email }).select('-password');
      if (user) res.json(user);
      else res.status(404).json({ message: 'User not found' });
  } catch (error) {
      res.status(500).json({ message: error.message });
  }
};

module.exports = { registerUser, updateUserProfile, getUserByEmail };