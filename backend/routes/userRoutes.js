const express = require('express');
const router = express.Router();
const {
  updateUserProfile,
  registerUser,
  getUserByEmail,
  updateFcmToken,
  getNotifications,
  markNotificationRead,
  searchUsers
} = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');
const {
  validateRegisterUser,
  validateUpdateFcmToken,
  validateSearchUser,
  handleValidationErrors
} = require('../middleware/validate');

// Define the endpoints
router.post('/', validateRegisterUser, handleValidationErrors, registerUser);
router.put('/profile', updateUserProfile);
router.get('/search', protect, validateSearchUser, handleValidationErrors, searchUsers);
router.get('/me', getUserByEmail);
router.put('/update-fcm-token', protect, validateUpdateFcmToken, handleValidationErrors, updateFcmToken);
router.get('/notifications', protect, getNotifications);
router.put('/notifications/:id/read', protect, markNotificationRead);

module.exports = router;