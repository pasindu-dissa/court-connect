const admin = require('firebase-admin');

try {
  let serviceAccount;

  // 1. Check if we are on Render (Cloud)
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    console.log("☁️ Attempting to load Firebase credentials from Render Environment Variable...");
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  } 
  // 2. Otherwise, check if we are on Localhost
  else {
    console.log("💻 No Environment Variable found. Attempting to load from local file...");
    serviceAccount = require('./firebase-service-account.json');
  }

  // 3. Initialize Firebase
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log("✅ Firebase Admin successfully initialized!");
  }
  
} catch (error) {
  // If it fails, print the exact reason to the console
  console.error("❌ Failed to initialize Firebase Admin:", error.message);
}

module.exports = admin;