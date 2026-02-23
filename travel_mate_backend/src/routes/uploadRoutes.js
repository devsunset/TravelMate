/**
 * 이미지 업로드 라우트
 * POST /api/upload/profile, /api/upload/post, /api/upload/itinerary
 * multipart 필드명: image, 인증 필수.
 */

const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const authMiddleware = require('../middlewares/authMiddleware');
const uploadController = require('../controllers/uploadController');

const router = express.Router();
const UPLOAD_DIR = path.resolve(__dirname, '../../uploads');

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

/** 이미지 확장자만 허용 */
const imageFilter = (req, file, cb) => {
  const allowed = /jpeg|jpg|png|gif|webp/i;
  const ext = path.extname(file.originalname).slice(1) || 'jpg';
  if (allowed.test(ext)) {
    cb(null, true);
  } else {
    cb(new Error('이미지 파일만 업로드 가능합니다.'), false);
  }
};

/** 프로필 이미지: uploads/profile/{uid}/{timestamp}.jpg */
const profileStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(UPLOAD_DIR, 'profile', req.user.uid);
    ensureDir(dir);
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}.jpg`);
  },
});

/** 게시글 이미지: uploads/posts/{uid}/{timestamp}.jpg */
const postStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(UPLOAD_DIR, 'posts', req.user.uid);
    ensureDir(dir);
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}.jpg`);
  },
});

/** 일정 이미지: uploads/itineraries/{uid}/{timestamp}.jpg */
const itineraryStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(UPLOAD_DIR, 'itineraries', req.user.uid);
    ensureDir(dir);
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}.jpg`);
  },
});

router.post('/profile', authMiddleware, multer({ storage: profileStorage, fileFilter: imageFilter }).single('image'), uploadController.uploadProfileImage);
router.post('/post', authMiddleware, multer({ storage: postStorage, fileFilter: imageFilter }).single('image'), uploadController.uploadPostImage);
router.post('/itinerary', authMiddleware, multer({ storage: itineraryStorage, fileFilter: imageFilter }).single('image'), uploadController.uploadItineraryImage);

module.exports = router;
