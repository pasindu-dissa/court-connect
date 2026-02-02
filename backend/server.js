const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

// 1. Load Config
dotenv.config();
connectDB();

const app = express();

// 2. Middleware
app.use(cors()); // Allows Flutter to talk to this server
app.use(express.json()); // Allows server to read JSON data

// 3. Routes
app.use('/api/users', require('./routes/userRoutes'));

// 4. Base Route
app.get('/', (req, res) => {
  res.send('CourtConnect API is running...');
});

// 5. Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});