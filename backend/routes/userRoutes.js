const express = require('express');
const router = express.Router();
const { updateUserProfile, registerUser } = require('../controllers/userController');

// Define the endpoints
router.post('/', registerUser); // POST http://localhost:5000/api/users (Create User)
router.put('/profile', updateUserProfile); // PUT http://localhost:5000/api/users/profile (Update Skills)

module.exports = router;