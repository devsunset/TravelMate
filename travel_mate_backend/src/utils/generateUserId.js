/**
 * 서비스 내 사용자 ID 생성 (랜덤 영문·숫자 조합)
 * 이메일 대신 사용하며 DB users.id(PK)에 저장됩니다.
 */
const LENGTH = 16;
const CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

function generateUserId() {
  let id = '';
  for (let i = 0; i < LENGTH; i++) {
    id += CHARS.charAt(Math.floor(Math.random() * CHARS.length));
  }
  return id;
}

module.exports = { generateUserId };
