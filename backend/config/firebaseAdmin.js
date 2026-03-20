const admin = require('firebase-admin');

// Check if we are in production (using env variable) or local (using file)
let serviceAccount;

if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  // If in cloud, parse the string from environment variables
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
} else {
  // If running locally, use the local file
  serviceAccount = require('./firebase-service-account.json');
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

module.exports = admin;
