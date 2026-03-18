const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const serviceAccountPath = path.join(
  __dirname,
  '../config/firebase-service-account.json'
);

let firebaseReady = false;

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }

  firebaseReady = true;
} else {
  console.warn(
    'Firebase service account file not found. Protected routes will be unavailable until it is added.'
  );
}

const protect = async (req, res, next) => {
  if (!firebaseReady) {
    return res.status(503).json({
      message:
        'Firebase admin is not configured on this server. Add backend/config/firebase-service-account.json to enable protected routes.',
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
      return res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    return res.status(401).json({ message: 'Not authorized, no token' });
  }
};

module.exports = { protect, authMiddleware: protect };
