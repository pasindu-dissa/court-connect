const mongoose = require('mongoose');

const courtSchema = new mongoose.Schema({
  name: { type: String, required: true },

  type: {
    type: String,
    enum: ['badminton', 'tennis', 'basketball', 'volleyball'],
    required: true
  },

  pricePerHour: { type: Number, required: true },

  location: {
    address: String,
    city: String,
    state: String,

    coordinates: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: {
        type: [Number], // [lng, lat]
        required: true
      }
    }
  },

  status: {
    type: String,
    enum: ['available', 'maintenance'],
    default: 'available'
  }
});

courtSchema.index({ 'location.coordinates': '2dsphere' });

module.exports = mongoose.model('Court', courtSchema);
