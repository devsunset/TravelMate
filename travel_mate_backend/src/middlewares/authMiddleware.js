/**
 * 인증 미들웨어
 * 요청 헤더의 Firebase ID 토큰을 검증하고, 성공 시 req.user에 디코딩된 토큰 정보를 담습니다.
 */

const admin = require('firebase-admin');

/**
 * Authorization: Bearer <idToken> 검증
 * @param {import('express').Request} req - Express 요청 객체
 * @param {import('express').Response} res - Express 응답 객체
 * @param {import('express').NextFunction} next - 다음 미들웨어/라우트 핸들러
 */
const authMiddleware = async (req, res, next) => {
  try {
    const idToken = req.headers.authorization?.split('Bearer ')[1];
    if (!idToken) {
      return res.status(401).send('Unauthorized: 토큰이 제공되지 않았습니다.');
    }
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Firebase ID 토큰 검증 오류:', error);
    res.status(401).send('Unauthorized: 유효하지 않은 토큰입니다.');
  }
};

module.exports = authMiddleware;
