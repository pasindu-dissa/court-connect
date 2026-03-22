const User = require('../models/User');
const cloudinary = require('../config/cloudinary');

// @desc    Get logged-in user profile
// @route   GET /api/users/profile
// @access  Protected
const getProfile = async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid })
      .select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      success: true,
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        bio: user.bio,
        profileImage: user.profileImage,
        role: user.role,
        district: user.district,
        city: user.city,
        location: user.location,
        skills: user.skills,
        stats: user.stats,
        createdAt: user.createdAt,
      }
    });
  } catch (error) {
    console.error('getProfile error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Protected
const updateProfile = async (req, res) => {
  try {
    const { name, phone, bio, district, city, location } = req.body;

    const user = await User.findOne({ firebaseUid: req.user.uid });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Only update fields that are provided
    if (name) user.name = name;
    if (phone) user.phone = phone;
    if (bio) user.bio = bio;
    if (district) user.district = district;
    if (city) user.city = city;
    if (location) user.location = location;

    const updatedUser = await user.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        id: updatedUser._id,
        name: updatedUser.name,
        email: updatedUser.email,
        phone: updatedUser.phone,
        bio: updatedUser.bio,
        profileImage: updatedUser.profileImage,
        role: updatedUser.role,
        district: updatedUser.district,
        city: updatedUser.city,
        location: updatedUser.location,
        skills: updatedUser.skills,
        stats: updatedUser.stats,
        createdAt: updatedUser.createdAt,
      }
    });
  } catch (error) {
    console.error('updateProfile error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Upload profile image to Cloudinary
// @route   PUT /api/users/profile/image
// @access  Protected
const uploadProfileImage = async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Delete old image from Cloudinary if exists
    if (user.profileImage && user.profileImage !== '') {
      const publicId = user.profileImage
        .split('/')
        .slice(-2)
        .join('/')
        .split('.')[0]; // Extract public_id from URL

      await cloudinary.uploader.destroy(publicId);
    }

    // Save new Cloudinary URL (multer-storage-cloudinary puts it in req.file)
    if (!req.file) {
      return res.status(400).json({ message: 'No image file provided' });
    }

    user.profileImage = req.file.path; // Cloudinary secure URL
    await user.save();

    res.json({
      success: true,
      message: 'Profile image updated successfully',
      profileImage: user.profileImage
    });
  } catch (error) {
    console.error('uploadProfileImage error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// @desc    Delete user account
// @route   DELETE /api/users/profile
// @access  Protected
const deleteAccount = async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Delete profile image from Cloudinary if exists
    if (user.profileImage && user.profileImage !== '') {
      const publicId = user.profileImage
        .split('/')
        .slice(-2)
        .join('/')
        .split('.')[0];
      await cloudinary.uploader.destroy(publicId);
    }

    await User.findByIdAndDelete(user._id);

    res.json({
      success: true,
      message: 'Account deleted successfully'
    });
  } catch (error) {
    console.error('deleteAccount error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

module.exports = { getProfile, updateProfile, uploadProfileImage, deleteAccount };