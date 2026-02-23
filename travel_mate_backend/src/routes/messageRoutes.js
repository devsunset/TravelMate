/** 1:1 쪽지 라우트. POST /api/messages/private (인증 필요) */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const messageController = require('../controllers/messageController');

router.use(authMiddleware);
router.post('/private', messageController.sendPrivateMessage);

module.exports = router;