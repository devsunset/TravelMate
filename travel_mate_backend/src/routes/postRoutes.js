/** 게시글: GET/POST /, GET/PATCH/DELETE /:postId (인증 필요) */
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const postController = require('../controllers/postController');

router.use(authMiddleware);
router.get('/', postController.getAllPosts);
router.get('/:postId', postController.getPostById);
router.post('/', postController.createPost);
router.patch('/:postId', postController.updatePost);
router.delete('/:postId', postController.deletePost);

module.exports = router;