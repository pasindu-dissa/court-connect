import { Router } from 'express';

import { createAiReply } from '../services/aiService.js';

const router = Router();

router.post('/chat', async (req, res, next) => {
  try {
    const { message, history = [], sessionId } = req.body ?? {};

    if (typeof message !== 'string' || !message.trim()) {
      return res.status(400).json({
        error: 'A non-empty message string is required.',
      });
    }

    if (!Array.isArray(history)) {
      return res.status(400).json({
        error: 'History must be an array.',
      });
    }

    const reply = await createAiReply({
      message: message.trim(),
      history,
      sessionId: typeof sessionId === 'string' ? sessionId : null,
    });

    return res.status(200).json(reply);
  } catch (error) {
    return next(error);
  }
});

export default router;
