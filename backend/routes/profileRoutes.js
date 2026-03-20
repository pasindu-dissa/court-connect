const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const {
  getProfile,
  updateProfile,
  uploadProfileImage,
  deleteAccount
} = require('../controllers/profileController');

// @route   GET /api/users/profile
router.get('/', protect, getProfile);

// @route   PUT /api/users/profile
router.put('/', protect, updateProfile);

// @route   PUT /api/users/profile/image
router.put('/image', protect, upload.single('profileImage'), uploadProfileImage);

// @route   DELETE /api/users/profile
router.delete('/', protect, deleteAccount);

module.exports = router;