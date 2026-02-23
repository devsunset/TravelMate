/**
 * 전역 에러 핸들링 미들웨어
 * 라우트/컨트롤러에서 발생한 오류를 일관된 JSON 형식으로 응답합니다.
 */

/**
 * Express 에러 핸들러 시그니처 (err, req, res, next) 4개 인자 필수
 * @param {Error} err - 발생한 오류 객체 (statusCode, message, errorCode 설정 가능)
 * @param {import('express').Request} req - Express 요청 객체
 * @param {import('express').Response} res - Express 응답 객체
 * @param {import('express').NextFunction} next - 다음 미들웨어 (미사용이어도 인자 유지 필요)
 */
const errorHandler = (err, req, res, next) => {
  console.error(err.stack);

  const statusCode = err.statusCode || 500;
  const message = err.message || '예기치 않은 오류가 발생했습니다.';
  const errorCode = err.errorCode || 'SERVER_ERROR';

  res.status(statusCode).json({
    message,
    errorCode,
    // 개발 환경에서만 스택 트레이스 노출
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
