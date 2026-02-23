/**
 * 사용자·프로필 라우트
 * GET /api/users/search (동행 검색), /:userId/profile (조회/수정), 계정 삭제 등
 * :userId 구간은 authMiddleware 적용.
 */

const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const userProfileController = require('../controllers/userProfileController');
const userSearchController = require('../controllers/userSearchController');
const userController = require('../controllers/userController');

router.get('/search', authMiddleware, userSearchController.searchCompanions);

router.use('/:userId', authMiddleware);
router.get('/:userId/profile', userProfileController.getUserProfile);
router.patch('/:userId/profile', userProfileController.updateUserProfile);
router.post('/:userId/profile/image', userProfileController.updateProfileImage);
router.delete('/:userId', userController.deleteUser);

module.exports = router;
