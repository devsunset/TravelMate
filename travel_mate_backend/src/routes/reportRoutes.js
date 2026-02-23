/** 신고 라우트. POST /api/reports/submit (인증 필요) */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const reportController = require('../controllers/reportController');

router.use(authMiddleware);
router.post('/submit', reportController.submitReport);

module.exports = router;