import 'dotenv/config';
import express from 'express';
import cors from 'cors';

import aiRoutes from './routes/aiRoutes.js';

const app = express();
const port = Number(process.env.PORT || 52445);

app.use(
  cors({
    origin: process.env.ALLOWED_ORIGIN || '*',
  }),
);
app.use(express.json({ limit: '1mb' }));

app.get('/api/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'court-connect-backend',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/ai', aiRoutes);

app.use((req, res) => {
  res.status(404).json({
    error: `Route not found: ${req.method} ${req.originalUrl}`,
  });
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({
    error: 'Something went wrong while processing the AI request.',
  });
});

app.listen(port, () => {
  console.log(`Court Connect backend listening on port ${port}`);
});
