const admin = require('../config/firebaseAdmin');

const protect = async (req, res, next) => {
  // Failsafe: Check if Firebase Admin initialized properly
  if (!admin.apps.length) {
    return res.status(500).json({ 
      message: 'Firebase admin is not configured on this server. Add FIREBASE_SERVICE_ACCOUNT to env or check config file.' 
    });
  }

  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Verify token with Firebase
      const decodedToken = await admin.auth().verifyIdToken(token);

      // Attach user info to request (uid, email)
      req.user = decodedToken;
      
      next();
    } catch (error) {
      console.error(error);
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Not authorized, no token' });
  }
};

module.exports = { protect };