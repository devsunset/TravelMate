/**
 * 인증 컨트롤러
 * Firebase ID 토큰 기반 회원가입·로그인 처리.
 */
const admin = require('firebase-admin');
const User = require('../models/user');

/** 회원가입: body.idToken 검증 후 DB에 없으면 사용자 생성, 있으면 기존 사용자 반환 */
exports.register = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ message: 'Firebase ID 토큰이 필요합니다.' });
    }
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const { uid, email } = decodedToken;
    let user = await User.findOne({ where: { firebase_uid: uid } });
    if (user) {
      return res.status(200).json({ message: '이미 등록된 사용자입니다.', user });
    }
    const userEmail = email || `user_${uid}@temp`;
    user = await User.create({ firebase_uid: uid, email: userEmail });
    res.status(201).json({ message: '회원가입이 완료되었습니다.', user });
  } catch (error) {
    console.error('authController.register 오류:', error);
    if (error.code === 'auth/id-token-expired' || error.code === 'auth/argument-error') {
      return res.status(401).json({ message: '유효하지 않거나 만료된 ID 토큰입니다.' });
    }
    next(error);
  }
};

/** 로그인: idToken 검증, DB에 없으면 자동 생성 후 로그인 처리 */
exports.login = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ message: 'Firebase ID 토큰이 필요합니다.' });
    }
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const { uid, email } = decodedToken;
    let user = await User.findOne({ where: { firebase_uid: uid } });
    if (!user) {
      const userEmail = email || `user_${uid}@temp`;
      user = await User.create({ firebase_uid: uid, email: userEmail });
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