/**
 * 인증 라우트
 * POST /api/auth/register, POST /api/auth/login
 */

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/register', authController.register);
router.post('/login', authController.login);

module.exports = router;
