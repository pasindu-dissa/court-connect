## Court Connect Backend

Clean Node.js backend for the chatbot demo.
The assistant is intentionally restricted to Court Connect and sports-related topics.

### Structure

- `src/index.js` -> starts Express
- `src/routes/aiRoutes.js` -> AI route
- `src/services/aiService.js` -> OpenAI, NLP intent filtering, and mock reply logic

### Endpoints

- `GET /api/health`
- `POST /api/ai/chat`

### Request body

```json
{
  "message": "Find me a badminton court tonight",
  "sessionId": "optional-session-id",
  "history": [
    { "role": "user", "content": "Hi" },
    { "role": "assistant", "content": "How can I help?" }
  ]
}
```

### Response body

```json
{
  "sessionId": "session-id",
  "reply": "I can help with court booking...",
  "source": "openai",
  "model": "gpt-4.1-mini",
  "responseId": "resp_123",
  "quickReplies": ["Show evening courts", "Find cheap venues"],
  "timestamp": "2026-03-15T00:00:00.000Z"
}
```

### Setup

1. Create `.env`
2. Add:

```env
PORT=52445
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4.1-mini
ALLOWED_ORIGIN=*
```

3. Run `npm install`
4. Run `npm.cmd run start`

### Domain Guardrails

- Off-topic prompts are filtered before they reach OpenAI.
- The backend uses the `natural` toolkit for lightweight intent classification.
- Court Coach should only answer Court Connect and sports-related questions.
