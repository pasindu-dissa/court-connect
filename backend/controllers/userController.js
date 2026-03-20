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

    // Send a quick in-app notification for profile updates
    updatedUser.notifications.unshift({
      title: 'Profile updated',
      body: 'Your profile has been saved successfully.',
      type: 'profile',
      read: false,
      createdAt: new Date()
    });
    await updatedUser.save();

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

// @desc    Update user's FCM Push Notification Token
// @route   PUT /api/users/update-fcm-token
// @access  Private
const updateFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({ message: 'FCM Token is required' });
    }

    const user = await User.findOneAndUpdate(
      { firebaseUid: req.user.uid || req.user.firebaseUid },
      { fcmToken: fcmToken },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ success: true, message: 'FCM Token updated successfully' });
  } catch (error) {
    console.error("Error updating FCM token:", error);
    res.status(500).json({ message: 'Server error while updating token' });
  }
};

// @desc    Get in-app notifications for logged in user
// @route   GET /api/users/notifications
// @access  Private
const getNotifications = async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid || req.user.firebaseUid }).select('notifications');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(200).json({ notifications: user.notifications || [] });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ message: 'Server error while fetching notifications' });
  }
};

// @desc    Mark notification as read
// @route   PUT /api/users/notifications/:id/read
// @access  Private
const markNotificationRead = async (req, res) => {
  try {
    const notificationId = req.params.id;
    const user = await User.findOne({ firebaseUid: req.user.uid || req.user.firebaseUid });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const note = user.notifications.id(notificationId);
    if (!note) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    note.read = true;
    await user.save();

    res.status(200).json({ message: 'Notification marked as read', notification: note });
  } catch (error) {
    console.error('Error marking notification read', error);
    res.status(500).json({ message: 'Server error while marking notification read' });
  }
};

module.exports = {
  registerUser,
  updateUserProfile,
  getUserByEmail,
  updateFcmToken,
  getNotifications,
  markNotificationRead
};