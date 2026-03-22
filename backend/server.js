const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');

const connectDB = require('./config/db');

dotenv.config();
connectDB();

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/matchmaking', require('./routes/matchmakingRoutes'));
app.use('/api/scores', require('./routes/scoreRoutes'));
app.use('/api/matches', require('./routes/matchRoutes'));
app.use('/api/courts', require('./routes/courtRoutes'));
app.use('/api/bookings', require('./routes/bookingRoutes'));
app.use('/api/users/profile', require('./routes/profileRoutes'));
app.use('/api/ai', require('./routes/aiRoutes'));
app.use('/api/player-leaderboard', require('./routes/playerLeaderboardRoutes'));

app.get('/', (_req, res) => {
  res.send('CourtConnect API is running...');
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({
    error: 'Something went wrong while processing the AI request.',
  });
});

const PORT = process.env.PORT || 5005;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  //CI/CD Pipeline
  console.log(`🐿️ CI/CD works!`);
});
