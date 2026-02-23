/**
 * 인증 컨트롤러
 * Firebase ID 토큰 기반 회원가입·로그인 처리. 사용자 식별은 랜덤 영숫자 id만 사용(이메일 미사용).
 */
const admin = require('firebase-admin');
const User = require('../models/user');
const { generateUserId } = require('../utils/generateUserId');

function ensureUser(uid) {
  return User.findOne({ where: { firebase_uid: uid } })
    .then(user => {
      if (user) return user;
      return User.create({ id: generateUserId(), firebase_uid: uid });
    });
}

/** 회원가입: body.idToken 검증 후 DB에 없으면 사용자 생성(랜덤 id), 있으면 기존 사용자 반환 */
exports.register = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ message: 'Firebase ID 토큰이 필요합니다.' });
    }
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const { uid } = decodedToken;
    let user = await User.findOne({ where: { firebase_uid: uid } });
    if (user) {
      return res.status(200).json({ message: '이미 등록된 사용자입니다.', user });
    }
    user = await User.create({ id: generateUserId(), firebase_uid: uid });
    res.status(201).json({ message: '회원가입이 완료되었습니다.', user });
  } catch (error) {
    console.error('authController.register 오류:', error);
    if (error.code === 'auth/id-token-expired' || error.code === 'auth/argument-error') {
      return res.status(401).json({ message: '유효하지 않거나 만료된 ID 토큰입니다.' });
    }
    next(error);
  }
};

/** 로그인: idToken 검증, DB에 없으면 랜덤 id로 자동 생성 후 로그인 처리 */
exports.login = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ message: 'Firebase ID 토큰이 필요합니다.' });
    }
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const { uid } = decodedToken;
    let user = await User.findOne({ where: { firebase_uid: uid } });
    if (!user) {
      user = await User.create({ id: generateUserId(), firebase_uid: uid });
      return res.status(201).json({ message: '계정이 생성되었고 로그인되었습니다.', user });
    }
    res.status(200).json({ message: '로그인되었습니다.', user });
  } catch (error) {
    console.error('authController.login 오류:', error);
    if (error.code === 'auth/id-token-expired' || error.code === 'auth/argument-error') {
      return res.status(401).json({ message: '유효하지 않거나 만료된 ID 토큰입니다.' });
    }
    next(error);
  }
};

/** 현재 로그인 사용자 ID 반환. 토큰 검증 후 없으면 생성 후 반환. */
exports.getMe = async (req, res, next) => {
  try {
    const uid = req.user?.uid;
    if (!uid) {
      return res.status(401).json({ message: '인증이 필요합니다.' });
    }
    const user = await ensureUser(uid);
    res.status(200).json({ userId: user.id });
  } catch (error) {
    console.error('authController.getMe 오류:', error);
    next(error);
  }
};