import crypto from 'node:crypto';

import natural from 'natural';
import OpenAI from 'openai';

const tokenizer = new natural.WordTokenizer();
const classifier = new natural.BayesClassifier();
const domainKeywords = {
  booking: [
    'book',
    'booking',
    'slot',
    'schedule',
    'reserve',
    'reservation',
    'price',
    'pricing',
    'availability',
    'court',
    'venue',
    'time',
  ],
  players: [
    'player',
    'players',
    'team',
    'invite',
    'partner',
    'double',
    'doubles',
    'squad',
    'group',
    'coach',
  ],
  preparation: [
    'match',
    'train',
    'training',
    'practice',
    'warmup',
    'warm-up',
    'checklist',
    'pack',
    'gear',
    'fitness',
    'hydration',
  ],
  sports: [
    'badminton',
    'tennis',
    'football',
    'basketball',
    'cricket',
    'swimming',
    'futsal',
    'sport',
    'sports',
    'tournament',
    'league',
  ],
  app: [
    'app',
    'courtconnect',
    'court',
    'connect',
    'profile',
    'notification',
    'leaderboard',
    'booking',
    'rank',
    'account',
  ],
};

trainClassifier();

const systemPrompt = `
You are Court Coach, the in-app assistant for Court Connect.
Help users book courts, find players, understand venue details, and prepare for matches.
Only answer questions related to Court Connect, sports, courts, players, venues, bookings, events, training, and match preparation.
If a user asks about anything outside those topics, politely refuse and redirect them back to app or sports-related help.
Keep answers concise, clear, and useful on a mobile screen.
`.trim();

export async function createAiReply({
  message,
  history,
  activityContext,
  sessionId,
}) {
  const currentSessionId = sessionId || crypto.randomUUID();
  const analysis = analyzeMessage(message);
  const client = getOpenAIClient();

  if (!analysis.isAllowed) {
    return buildDomainGuardrailReply({
      sessionId: currentSessionId,
    });
  }

  if (!client) {
    return buildMockReply({
      message,
      sessionId: currentSessionId,
      intent: analysis.intent,
    });
  }

  const response = await client.responses.create({
    model: process.env.OPENAI_MODEL || 'gpt-4.1-mini',
    instructions: buildSystemPrompt(activityContext),
    input: [
      ...sanitizeHistory(history),
      {
        role: 'user',
        content: message,
      },
    ],
  });

  return {
    sessionId: currentSessionId,
    reply:
      response.output_text?.trim() ||
      'I could not generate a response just now. Please try again in a moment.',
    source: 'openai',
    model: response.model || process.env.OPENAI_MODEL || 'gpt-4.1-mini',
    responseId: response.id,
    quickReplies: buildQuickReplies(analysis.intent),
    timestamp: new Date().toISOString(),
  };
}

function getOpenAIClient() {
  if (!process.env.OPENAI_API_KEY) {
    return null;
  }

  return new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
}

function buildSystemPrompt(activityContext) {
  if (!activityContext) {
    return systemPrompt;
  }

  return `${systemPrompt}

Recent in-app activity context:
${JSON.stringify(activityContext)}

Use this activity context only when it helps answer the user's sports or Court Connect question more personally and accurately.`;
}

function sanitizeHistory(history) {
  return history
    .filter(
      (item) =>
        item &&
        (item.role === 'user' || item.role === 'assistant') &&
        typeof item.content === 'string' &&
        item.content.trim(),
    )
    .slice(-12)
    .map((item) => ({
      role: item.role,
      content: item.content.trim(),
    }));
}

function trainClassifier() {
  const trainingSet = [
    ['book a badminton court tonight', 'booking'],
    ['show available court slots', 'booking'],
    ['how much is a tennis court', 'booking'],
    ['reserve a venue for tomorrow', 'booking'],
    ['find doubles players', 'players'],
    ['help me invite my team', 'players'],
    ['looking for a badminton partner', 'players'],
    ['draft a player invite message', 'players'],
    ['give me a match checklist', 'preparation'],
    ['what should i pack for training', 'preparation'],
    ['how early should i arrive', 'preparation'],
    ['best warmup before a game', 'preparation'],
    ['what sports are available in the app', 'sports'],
    ['show me badminton venues', 'sports'],
    ['how do i use the booking feature', 'app'],
    ['where is the profile screen', 'app'],
    ['help with notifications and account', 'app'],
    ['tell me a joke', 'off_topic'],
    ['write me a poem', 'off_topic'],
    ['what is the stock market today', 'off_topic'],
    ['who won an election', 'off_topic'],
  ];

  for (const [text, label] of trainingSet) {
    classifier.addDocument(normalizeText(text), label);
  }

  classifier.train();
}

function analyzeMessage(message) {
  const normalized = normalizeText(message);
  const tokens = normalized.split(' ').filter(Boolean);
  const keywordMatches = countKeywordMatches(tokens);
  const classification = classifier.getClassifications(normalized);
  const topResult = classification[0] || { label: 'general', value: 0 };
  const allowedKeywordScore =
    keywordMatches.booking +
    keywordMatches.players +
    keywordMatches.preparation +
    keywordMatches.sports +
    keywordMatches.app;
  const isClearlyOffTopic =
    topResult.label === 'off_topic' &&
    topResult.value >= 0.35 &&
    allowedKeywordScore === 0;
  const isAllowed =
    !isClearlyOffTopic &&
    (allowedKeywordScore > 0 || topResult.label !== 'off_topic');

  return {
    isAllowed,
    intent: selectIntent(topResult.label, keywordMatches),
  };
}

function normalizeText(text) {
  return tokenizer
    .tokenize(String(text).toLowerCase())
    .map((token) => natural.PorterStemmer.stem(token))
    .join(' ');
}

function countKeywordMatches(tokens) {
  const tokenSet = new Set(tokens);
  const matches = {};

  for (const [label, words] of Object.entries(domainKeywords)) {
    matches[label] = words
      .map((word) => natural.PorterStemmer.stem(word.toLowerCase()))
      .filter((word) => tokenSet.has(word)).length;
  }

  return matches;
}

function selectIntent(classifierLabel, keywordMatches) {
  if (keywordMatches.booking > 0 || classifierLabel === 'booking') {
    return 'booking';
  }

  if (keywordMatches.players > 0 || classifierLabel === 'players') {
    return 'players';
  }

  if (keywordMatches.preparation > 0 || classifierLabel === 'preparation') {
    return 'preparation';
  }

  return 'general';
}

function buildQuickReplies(intent) {
  switch (intent) {
    case 'booking':
      return ['Show evening courts', 'Find cheap venues', 'What is available?'];
    case 'players':
      return ['Find doubles players', 'Draft an invite', 'Suggest skill levels'];
    case 'preparation':
      return ['Give me a checklist', 'What should I pack?', 'How early to arrive?'];
    default:
      return ['Book a court', 'Find players', 'Get match tips'];
  }
}

function buildDomainGuardrailReply({ sessionId }) {
  return {
    sessionId,
    reply:
      'I can only help with Court Connect and sports topics, like bookings, venues, players, training, and match preparation. Try asking about courts, schedules, teams, or game-day prep.',
    source: 'guardrail',
    model: 'domain-filter',
    responseId: null,
    quickReplies: ['Book a court', 'Find players', 'Match checklist'],
    timestamp: new Date().toISOString(),
  };
}

function buildMockReply({ message, sessionId, intent }) {
  const replies = {
    booking:
        'I can help you book faster. Tell me the sport, time, and budget, and I will narrow the best options.',
    players:
        'I can help organize players. Tell me how many players you need and the expected skill level.',
    preparation:
        'For match prep, I would suggest a quick checklist with gear, hydration, and arrival time.',
    general:
        `Court Coach is ready. You said: "${message}". I can help with booking, players, venue questions, or match prep.`,
  };

  return {
    sessionId,
    reply: replies[intent] || replies.general,
    source: 'mock',
    model: 'mock-court-coach',
    responseId: null,
    quickReplies: buildQuickReplies(intent),
    timestamp: new Date().toISOString(),
  };
}
