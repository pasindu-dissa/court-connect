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
const { protect } = require('../middleware/authMiddleware'); // Your auth middleware

// Define the endpoints
router.post('/', registerUser); // POST http://localhost:5000/api/users (Create User)
router.put('/profile', updateUserProfile); // PUT http://localhost:5000/api/users/profile (Update Skills)
router.get('/search', protect, searchUsers);
router.get('/me', getUserByEmail);
router.put('/update-fcm-token', protect, updateFcmToken);
router.get('/notifications', protect, getNotifications);
router.put('/notifications/:id/read', protect, markNotificationRead);

module.exports = router;