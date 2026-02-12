/** 채팅방: POST /api/chat/room (인증 필요) */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const chatController = require('../controllers/chatController');

router.use(authMiddleware);
router.post('/room', chatController.createChatRoom);

module.exports = router;