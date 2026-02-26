const mongoose = require('mongoose');

const courtSchema = new mongoose.Schema({
  name: { type: String, required: true },
  sport: { type: String, required: true },
  price: { type: Number, required: true },
  maxCapacity: { type: Number, required: true },
  loc: {
    lat: { type: Number, required: true },
    lon: { type: Number, required: true }
  }
}, { timestamps: true });

module.exports = mongoose.model('Court', courtSchema);