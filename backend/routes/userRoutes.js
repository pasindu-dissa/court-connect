const express = require('express');
const router = express.Router();
const { updateUserProfile, registerUser, getUserByEmail } = require('../controllers/userController');

// Define the endpoints
router.post('/', registerUser); // POST http://localhost:5000/api/users (Create User)
router.put('/profile', updateUserProfile); // PUT http://localhost:5000/api/users/profile (Update Skills)
// Add route in userRoutes.js
router.get('/me', getUserByEmail);

module.exports = router;