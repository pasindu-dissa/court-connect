const express = require("express");
const router = express.Router();

const scoreController = require("../controllers/scoreController");
const { validateSubmitScore, handleValidationErrors } = require('../middleware/validate');

router.post("/submit", validateSubmitScore, handleValidationErrors, scoreController.submitScore);

module.exports = router;

