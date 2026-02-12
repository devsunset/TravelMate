/** FCM 토큰: POST/DELETE /api/fcm/token (인증 필요) */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const fcmController = require('../controllers/fcmController');

router.use(authMiddleware);
router.post('/token', fcmController.registerFcmToken);
router.delete('/token', fcmController.deleteFcmToken);

module.exports = router;