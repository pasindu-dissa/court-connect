const express = require('express');
const router = express.Router();
const upload = require('../config/cloudinary'); // Import the file you just made

// The 'image' inside upload.single() must match the field name sent from Flutter
router.post('/upload', upload.single('image'), (req, res) => {
  try {
    // req.file.path contains the secure Cloudinary URL!
    const imageUrl = req.file.path; 
    
    // You can now save this URL to your MongoDB User or Court document
    res.status(200).json({ 
      success: true, 
      imageUrl: imageUrl 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Upload failed" });
  }
});

module.exports = router;
