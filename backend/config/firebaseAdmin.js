const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json'); // Using your existing file!

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

module.exports = admin;
