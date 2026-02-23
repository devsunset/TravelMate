/**
 * 인증 라우트
 * POST /api/auth/register, POST /api/auth/login, GET /api/auth/me (인증 필요)
 */

const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/me', authMiddleware, authController.getMe);

module.exports = router;
