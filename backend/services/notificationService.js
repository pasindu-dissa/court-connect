const admin = require('../config/firebaseAdmin');
const User = require('../models/User');

const pushNotificationToUser = async (userId, title, body, data = {}) => {
  try {
    const user = await User.findById(userId);
    if (!user) return null;

    // Save in-app notification list
    user.notifications = user.notifications || [];
    user.notifications.unshift({
      title,
      body,
      type: data.type || 'general',
      read: false,
      createdAt: new Date()
    });
    if (user.notifications.length > 80) {
      user.notifications = user.notifications.slice(0, 80);
    }

    await user.save();

    // Send FCM push if token exists
    if (!user.fcmToken) return null;

    const message = {
      token: user.fcmToken,
      notification: {
        title,
        body
      },
      data: {
        ...data
      }
    };

    await admin.messaging().send(message);
    return true;
  } catch (error) {
    console.error('pushNotificationToUser error:', error.message || error);
    return null;
  }
};

const getNotificationsForUser = async (userId) => {
  const user = await User.findById(userId).select('notifications');
  return user ? user.notifications : [];
};

const markNotificationRead = async (userId, notificationId) => {
  const user = await User.findById(userId);
  if (!user) return null;
  const note = user.notifications.id(notificationId);
  if (!note) return null;
  note.read = true;
  await user.save();
  return note;
};

module.exports = { pushNotificationToUser, getNotificationsForUser, markNotificationRead };