/** 댓글: GET/POST /, PATCH/DELETE /:commentId (인증 필요) */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const commentController = require('../controllers/commentController');

router.use(authMiddleware);
router.get('/', commentController.getComments);
router.post('/', commentController.addComment);
router.patch('/:commentId', commentController.updateComment);
router.delete('/:commentId', commentController.deleteComment);

module.exports = router;