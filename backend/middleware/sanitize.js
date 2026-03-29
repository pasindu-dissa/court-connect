/**
 * Global sanitization middleware.
 * Runs on EVERY request before any route handlers.
 *
 * Protections applied:
 *  1. Trim leading/trailing whitespace from all string values in
 *     req.body, req.query, and req.params.
 *  2. Strip keys that start with '$' from req.body to prevent
 *     MongoDB/NoSQL operator injection (e.g. { "$gt": "" }).
 *  3. Replace '<' and '>' in strings to neutralise basic XSS payloads
 *     stored into the DB.
 */

function sanitizeStrings(obj) {
  if (!obj || typeof obj !== 'object') return obj;

  for (const key of Object.keys(obj)) {
    const val = obj[key];

    // 2. Strip MongoDB operator keys from body objects
    if (key.startsWith('$')) {
      delete obj[key];
      continue;
    }

    if (typeof val === 'string') {
      // 1. Trim whitespace
      let clean = val.trim();
      // 3. Basic XSS guard — encode angle brackets
      clean = clean.replace(/</g, '&lt;').replace(/>/g, '&gt; ');
      obj[key] = clean;
    } else if (Array.isArray(val)) {
      val.forEach((item, i) => {
        if (typeof item === 'string') {
          val[i] = item.trim().replace(/</g, '&lt;').replace(/>/g, '&gt;');
        } else if (typeof item === 'object') {
          sanitizeStrings(item);
        }
      });
    } else if (typeof val === 'object' && val !== null) {
      sanitizeStrings(val);
    }
  }

  return obj;
}

const sanitize = (req, _res, next) => {
  if (req.body)   sanitizeStrings(req.body);
  if (req.query)  sanitizeStrings(req.query);
  if (req.params) sanitizeStrings(req.params);
  next();
};

module.exports = sanitize;
