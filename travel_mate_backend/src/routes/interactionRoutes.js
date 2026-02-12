/** 좋아요·북마크 라우트. POST /api/interactions/toggleLike, toggleBookmark (인증 필요) */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const interactionController = require('../controllers/interactionController');

router.use(authMiddleware);
router.post('/toggleLike', interactionController.toggleLike);
router.post('/toggleBookmark', interactionController.toggleBookmark);

module.exports = router;