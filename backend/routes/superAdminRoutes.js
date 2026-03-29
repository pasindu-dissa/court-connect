const express = require('express');
const router = express.Router();
const verifySuperAdmin = require('../middleware/verifySuperAdmin');
const { checkAuth, getUsers, updateRole } = require('../controllers/superAdminController');

router.post('/auth', verifySuperAdmin, checkAuth);
router.get('/users', verifySuperAdmin, getUsers);
router.put('/users/:id/role', verifySuperAdmin, updateRole);

module.exports = router;
