/**
 * FCM 푸시 알림 서비스
 * 수신자 Firebase UID로 등록된 모든 FCM 토큰에 멀티캐스트 전송.
 */
const admin = require('firebase-admin');
const FcmToken = require('../models/fcmToken');
const User = require('../models/user');

/**
 * FCM 푸시 발송
 * @param {string} receiverFirebaseUid - 수신자 Firebase UID
 * @param {object} payload - { title, body, data }
 */
exports.sendFCM = async (receiverFirebaseUid, payload) => {
  try {
    const receiver = await User.findOne({ where: { firebase_uid: receiverFirebaseUid } });
    if (!receiver) {
      console.warn(`FCM: 수신자 없음 UID=${receiverFirebaseUid}`);
      return;
    }

    const fcmTokens = await FcmToken.findAll({
      where: { userId: receiver.id },
      attributes: ['token'],
    });
    const tokens = fcmTokens.map((fcmToken) => fcmToken.token);

    if (tokens.length === 0) {
      console.log(`FCM: 사용자 ${receiverFirebaseUid}에 토큰 없음. 알림 미발송.`);
      return;
    }

    const message = {
      notification: {
        title: payload.title || '새 알림',
        body: payload.body || '새 알림이 도착했습니다.',
      },
      data: payload.data || {},
      tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`FCM 전송 실패 token=${tokens[idx]}`, resp.exception?.message);
        }
      });
    }
  } catch (error) {
    console.error('FCM 발송 오류:', error);
  }
};
