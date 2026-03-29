/**
 * Validation rule sets for every route that accepts user input.
 *
 * Usage in a route file:
 *   const { validateCreateBooking, handleValidationErrors } = require('../middleware/validate');
 *   router.post('/', [...validateCreateBooking], handleValidationErrors, controller);
 */

const { body, query, param, validationResult } = require('express-validator');

// ─── Shared error handler ────────────────────────────────────────────────────

/**
 * Run after a validation chain. Returns 422 with all error details if any
 * rule failed; otherwise calls next().
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }
  next();
};

// ─── Helper: escape string for safe regex use ────────────────────────────────
function escapeRegex(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// ─── User ────────────────────────────────────────────────────────────────────

const validateRegisterUser = [
  body('firebaseUid')
    .notEmpty().withMessage('firebaseUid is required')
    .isString().trim(),
  body('name')
    .notEmpty().withMessage('Name is required')
    .isString().trim()
    .isLength({ max: 100 }).withMessage('Name must be at most 100 characters'),
  body('email')
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Must be a valid email address')
    .normalizeEmail(),
  body('age')
    .optional()
    .isInt({ min: 5, max: 120 }).withMessage('Age must be an integer between 5 and 120'),
  body('district').optional().isString().trim().isLength({ max: 100 }),
  body('city').optional().isString().trim().isLength({ max: 100 }),
  body('location').optional().isString().trim().isLength({ max: 200 }),
  body('password').optional().isString(),
];

const validateUpdateProfile = [
  body('name')
    .optional()
    .isString().trim()
    .isLength({ min: 1, max: 100 }).withMessage('Name must be 1–100 characters'),
  body('phone')
    .optional()
    .matches(/^\+?[\d\s\-]{7,15}$/).withMessage('Phone must be 7–15 digits, optionally starting with +'),
  body('bio')
    .optional()
    .isString().trim()
    .isLength({ max: 500 }).withMessage('Bio must be at most 500 characters'),
  body('district').optional().isString().trim().isLength({ max: 100 }),
  body('city').optional().isString().trim().isLength({ max: 100 }),
  body('location').optional().isString().trim().isLength({ max: 200 }),
];

const validateSearchUser = [
  query('q')
    .optional()
    .isString().trim()
    .customSanitizer(val => escapeRegex(val || '')),
];

const validateUpdateFcmToken = [
  body('fcmToken')
    .notEmpty().withMessage('FCM token is required')
    .isString().trim(),
];

// ─── Booking ─────────────────────────────────────────────────────────────────

const validateCreateBooking = [
  body('courtId')
    .notEmpty().withMessage('courtId is required')
    .isMongoId().withMessage('courtId must be a valid ID'),
  body('userId')
    .notEmpty().withMessage('userId is required')
    .isMongoId().withMessage('userId must be a valid ID'),
  body('date')
    .notEmpty().withMessage('date is required')
    .matches(/^\d{4}-\d{2}-\d{2}$/).withMessage('date must be YYYY-MM-DD'),
  body('startTime')
    .notEmpty().withMessage('startTime is required')
    .isString().trim(),
  body('totalPrice')
    .notEmpty().withMessage('totalPrice is required')
    .isFloat({ min: 0 }).withMessage('totalPrice must be a non-negative number'),
];

// ─── Court ───────────────────────────────────────────────────────────────────

const validateAddCourt = [
  body('name')
    .notEmpty().withMessage('Court name is required')
    .isString().trim()
    .isLength({ max: 150 }),
  body('location')
    .notEmpty().withMessage('Location is required')
    .isString().trim()
    .isLength({ max: 300 }),
  body('district').optional().isString().trim().isLength({ max: 100 }),
  body('pricePerHour')
    .optional()
    .isFloat({ min: 0 }).withMessage('pricePerHour must be a non-negative number'),
  body('contactNumber')
    .optional()
    .matches(/^\+?[\d\s\-]{7,15}$/).withMessage('Invalid contact number format'),
  body('latitude')
    .optional()
    .isFloat({ min: -90, max: 90 }).withMessage('latitude must be between -90 and 90'),
  body('longitude')
    .optional()
    .isFloat({ min: -180, max: 180 }).withMessage('longitude must be between -180 and 180'),
  body('description').optional().isString().trim().isLength({ max: 1000 }),
];

// ─── Match ───────────────────────────────────────────────────────────────────

const validateCreateMatch = [
  body('hostId')
    .notEmpty().withMessage('hostId is required')
    .isMongoId().withMessage('hostId must be a valid ID'),
  body('sport')
    .notEmpty().withMessage('sport is required')
    .isString().trim()
    .isLength({ max: 50 }),
  body('date')
    .notEmpty().withMessage('date is required')
    .matches(/^\d{4}-\d{2}-\d{2}$/).withMessage('date must be YYYY-MM-DD'),
  body('time')
    .notEmpty().withMessage('time is required')
    .isString().trim(),
  body('maxPlayers')
    .optional()
    .isInt({ min: 2, max: 22 }).withMessage('maxPlayers must be between 2 and 22'),
  body('location').optional().isString().trim().isLength({ max: 300 }),
  body('description').optional().isString().trim().isLength({ max: 500 }),
];

const validateUpdateMatch = [
  body('sport').optional().isString().trim().isLength({ max: 50 }),
  body('date')
    .optional()
    .matches(/^\d{4}-\d{2}-\d{2}$/).withMessage('date must be YYYY-MM-DD'),
  body('time').optional().isString().trim(),
  body('maxPlayers')
    .optional()
    .isInt({ min: 2, max: 22 }).withMessage('maxPlayers must be between 2 and 22'),
  body('location').optional().isString().trim().isLength({ max: 300 }),
  body('description').optional().isString().trim().isLength({ max: 500 }),
  body('status')
    .optional()
    .isIn(['Open', 'Full', 'Completed']).withMessage('status must be Open, Full, or Completed'),
];

const validateRequestJoin = [
  body('userId')
    .notEmpty().withMessage('userId is required')
    .isMongoId().withMessage('userId must be a valid ID'),
];

const validateApproveRejectPlayer = [
  body('playerId')
    .notEmpty().withMessage('playerId is required')
    .isMongoId().withMessage('playerId must be a valid ID'),
];

// ─── Score ───────────────────────────────────────────────────────────────────

const validateSubmitScore = [
  body('matchId')
    .notEmpty().withMessage('matchId is required')
    .isMongoId().withMessage('matchId must be a valid ID'),
  body('userId')
    .notEmpty().withMessage('userId is required')
    .isMongoId().withMessage('userId must be a valid ID'),
  body('score').notEmpty().withMessage('score is required').isObject(),
  body('score.teamA')
    .notEmpty().withMessage('score.teamA is required')
    .isInt({ min: 0 }).withMessage('score.teamA must be a non-negative integer'),
  body('score.teamB')
    .notEmpty().withMessage('score.teamB is required')
    .isInt({ min: 0 }).withMessage('score.teamB must be a non-negative integer'),
  body('players')
    .isArray({ min: 1 }).withMessage('players must be a non-empty array'),
  body('sport').optional().isString().trim().isLength({ max: 50 }),
];

// ─── Team ────────────────────────────────────────────────────────────────────

const validateCreateTeam = [
  body('name')
    .notEmpty().withMessage('Team name is required')
    .isString().trim()
    .isLength({ max: 100 }),
  body('sport')
    .notEmpty().withMessage('sport is required')
    .isString().trim()
    .isLength({ max: 50 }),
];

const validateJoinTeam = [
  body('teamId')
    .notEmpty().withMessage('teamId is required')
    .isMongoId().withMessage('teamId must be a valid ID'),
];

// ─── Leaderboard ─────────────────────────────────────────────────────────────

const validateInitLeaderboard = [
  body('groupId')
    .notEmpty().withMessage('groupId is required')
    .isMongoId().withMessage('groupId must be a valid ID'),
  body('sport')
    .notEmpty().withMessage('sport is required')
    .isString().trim()
    .isLength({ max: 50 }),
  body('teams')
    .isArray({ min: 1 }).withMessage('teams must be a non-empty array')
    .custom(teams => teams.every(t => typeof t === 'string' && t.trim().length > 0))
    .withMessage('Each team must be a non-empty string'),
];

const validateRecordMatchResult = [
  body('groupId')
    .notEmpty().withMessage('groupId is required')
    .isMongoId().withMessage('groupId must be a valid ID'),
  body('sport')
    .notEmpty().withMessage('sport is required')
    .isString().trim()
    .isLength({ max: 50 }),
  body('team1Name')
    .notEmpty().withMessage('team1Name is required')
    .isString().trim()
    .isLength({ max: 100 }),
  body('team2Name')
    .notEmpty().withMessage('team2Name is required')
    .isString().trim()
    .isLength({ max: 100 }),
  body('team1Score')
    .notEmpty().withMessage('team1Score is required')
    .isInt({ min: 0 }).withMessage('team1Score must be a non-negative integer'),
  body('team2Score')
    .notEmpty().withMessage('team2Score is required')
    .isInt({ min: 0 }).withMessage('team2Score must be a non-negative integer'),
  body('venue').optional().isString().trim().isLength({ max: 200 }),
  body('matchType').optional().isString().trim().isLength({ max: 50 }),
  body('notes').optional().isString().trim().isLength({ max: 500 }),
];

const validateAwardPoint = [
  body('userId')
    .notEmpty().withMessage('userId is required')
    .isMongoId().withMessage('userId must be a valid ID'),
  body('courtId')
    .notEmpty().withMessage('courtId is required')
    .isString().trim(),
  body('sportType')
    .notEmpty().withMessage('sportType is required')
    .isString().trim()
    .isLength({ max: 50 }),
];

const validateUpdateTeamStats = [
  body('matchesPlayed').optional().isInt({ min: 0 }),
  body('matchesWon').optional().isInt({ min: 0 }),
  body('matchesLost').optional().isInt({ min: 0 }),
  body('matchesDraw').optional().isInt({ min: 0 }),
  body('points').optional().isInt({ min: 0 }),
  body('goalsFor').optional().isInt({ min: 0 }),
  body('goalsAgainst').optional().isInt({ min: 0 }),
];

// ─── Exports ─────────────────────────────────────────────────────────────────

module.exports = {
  handleValidationErrors,
  // User
  validateRegisterUser,
  validateUpdateProfile,
  validateSearchUser,
  validateUpdateFcmToken,
  // Booking
  validateCreateBooking,
  // Court
  validateAddCourt,
  // Match
  validateCreateMatch,
  validateUpdateMatch,
  validateRequestJoin,
  validateApproveRejectPlayer,
  // Score
  validateSubmitScore,
  // Team
  validateCreateTeam,
  validateJoinTeam,
  // Leaderboard
  validateInitLeaderboard,
  validateRecordMatchResult,
  validateAwardPoint,
  validateUpdateTeamStats,
};
