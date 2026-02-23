/**
 * 영문+숫자 조합 랜덤 닉네임 생성 (예: user_a7k2m9x1)
 * 항상 DB에 기존 닉네임이 있는지 조회해서 중복이 없을 때만 반환합니다.
 */

const UserProfile = require('../models/userProfile');

const PREFIX = 'user_';
const ALPHANUM = 'abcdefghijklmnopqrstuvwxyz0123456789';

/**
 * 영문 소문자 + 숫자 랜덤 문자열 생성 (DB 미검사, 내부용)
 * @param {number} length - 길이 (기본 8)
 */
function randomAlphanumeric(length = 8) {
  let s = '';
  for (let i = 0; i < length; i++) {
    s += ALPHANUM[Math.floor(Math.random() * ALPHANUM.length)];
  }
  return s;
}

/**
 * 영문_숫자 형식 랜덤 닉네임 하나 생성 (DB 미검사)
 */
function generateRandomNickname() {
  return `${PREFIX}${randomAlphanumeric(8)}`;
}

/**
 * DB에 해당 닉네임이 이미 있는지 조회
 * @param {string} nickname
 * @returns {Promise<boolean>}
 */
async function isNicknameTaken(nickname) {
  const existing = await UserProfile.findOne({ where: { nickname } });
  return !!existing;
}

/**
 * 다른 사용자(본인 제외)가 해당 닉네임을 쓰고 있는지 조회
 * @param {string} nickname
 * @param {number} excludeUserId - 제외할 userId (본인)
 * @returns {Promise<boolean>}
 */
async function isNicknameTakenByOther(nickname, excludeUserId) {
  const existing = await UserProfile.findOne({
    where: { nickname },
  });
  return !!existing && existing.userId !== excludeUserId;
}

/**
 * DB에 없는 고유한 영문_숫자 닉네임 생성.
 * 매번 기존 user_profiles 테이블을 조회해서 중복이 아닐 때만 반환합니다.
 *
 * @param {number} maxRetries - 재시도 횟수 (기본 20)
 * @returns {Promise<string>} DB에 없는 고유 닉네임
 */
async function generateUniqueRandomNickname(maxRetries = 20) {
  for (let i = 0; i < maxRetries; i++) {
    const nickname = generateRandomNickname();
    if (!(await isNicknameTaken(nickname))) return nickname;
  }
  // 길이 늘려서 재시도
  let nickname;
  do {
    nickname = `${PREFIX}${randomAlphanumeric(12)}`;
  } while (await isNicknameTaken(nickname));
  return nickname;
}

module.exports = {
  isNicknameTaken,
  isNicknameTakenByOther,
  generateRandomNickname,
  generateUniqueRandomNickname,
};
