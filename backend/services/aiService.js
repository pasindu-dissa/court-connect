const OpenAI = require('openai');

const allowedKeywords = [
  'book',
  'booking',
  'court',
  'courts',
  'venue',
  'venues',
  'match',
  'matches',
  'player',
  'players',
  'team',
  'badminton',
  'tennis',
  'cricket',
  'football',
  'basketball',
  'swimming',
  'leaderboard',
  'rank',
  'profile',
  'training',
  'practice',
];

async function createAiReply({ message, history }) {
  const isAllowed = allowedKeywords.some((keyword) =>
    message.toLowerCase().includes(keyword)
  );

  if (!isAllowed) {
    return {
      reply:
        'I can only help with Court Connect and sports topics like bookings, venues, players, leaderboard, and match preparation.',
      source: 'guardrail',
    };
  }

  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    return {
      reply: buildMockReply(message),
      source: 'mock',
    };
  }

  try {
    const client = new OpenAI({ apiKey });
    const response = await client.responses.create({
      model: process.env.OPENAI_MODEL || 'gpt-4.1-mini',
      instructions:
        'You are Court Coach, the in-app assistant for Court Connect. Help users with bookings, venues, finding players, match preparation, and in-app sports questions. Refuse off-topic requests politely. Keep answers concise and mobile-friendly.',
      input: [
        ...sanitizeHistory(history),
        {
          role: 'user',
          content: message,
        },
      ],
    });

    return {
      reply:
        response.output_text?.trim() ||
        'I could not generate a response just now. Please try again in a moment.',
      source: 'openai',
    };
  } catch (error) {
    console.error('OpenAI request failed, falling back to mock reply.', error);
    return {
      reply: buildMockReply(message),
      source: 'mock',
    };
  }
}

function sanitizeHistory(history) {
  return history
    .filter(
      (item) =>
        item &&
        (item.role === 'user' || item.role === 'assistant') &&
        typeof item.content === 'string' &&
        item.content.trim()
    )
    .slice(-10)
    .map((item) => ({
      role: item.role,
      content: item.content.trim(),
    }));
}

function buildMockReply(message) {
  const text = message.toLowerCase();

  if (text.includes('book')) {
    return 'Tell me the sport, time, and budget, and I can help narrow down the best booking options.';
  }

  if (text.includes('player') || text.includes('team')) {
    return 'I can help organize players. Tell me how many players you need and the skill level you want.';
  }

  if (text.includes('match') ||
      text.includes('pack') ||
      text.includes('practice')) {
    return 'For match prep, focus on gear, hydration, and arriving early enough for a proper warm-up.';
  }

  return 'Court Coach is ready. Ask me about booking courts, finding players, venues, rankings, or match preparation.';
}

module.exports = { createAiReply };
