/**
 * 채팅방 컨트롤러
 * 두 사용자 간 채팅방 생성. firestoreChatId는 UID 정렬 후 조합.
 */
const ChatRoom = require('../models/chatRoom');
const User = require('../models/user');
const { Op } = require('sequelize');

/** 채팅방 생성: partnerId와 현재 사용자로 방이 없으면 생성, 있으면 기존 firestoreChatId 반환 */
exports.createChatRoom = async (req, res, next) => {
  try {
    const { partnerId } = req.body;
    const currentFirebaseUid = req.user.uid;
    if (!partnerId) {
      return res.status(400).json({ message: '채팅 상대 ID가 필요합니다.' });
    }
    const currentUser = await User.findOne({ where: { firebase_uid: currentFirebaseUid } });
    const partnerUser = await User.findOne({ where: { firebase_uid: partnerId } });
    if (!currentUser || !partnerUser) {
      return res.status(404).json({ message: '사용자 또는 상대를 찾을 수 없습니다.' });
    }
    const firestoreChatId = [currentFirebaseUid, partnerId].sort().join('_');
    let chatRoom = await ChatRoom.findOne({
      where: {
        firestoreChatId: firestoreChatId,
        [Op.or]: [
          { user1Id: currentUser.id, user2Id: partnerUser.id },
          { user1Id: partnerUser.id, user2Id: currentUser.id },
        ],
      },
    });

    if (chatRoom) {
      return res.status(200).json({ message: 'Chat room already exists', chatRoomId: chatRoom.firestoreChatId });
    }

    // Create new chat room in MariaDB
    chatRoom = await ChatRoom.create({
      firestoreChatId: firestoreChatId,
      user1Id: currentUser.id,
      user2Id: partnerUser.id,
    });

    res.status(201).json({ message: '채팅방이 생성되었습니다.', chatRoomId: chatRoom.firestoreChatId });
  } catch (error) {
    console.error('createChatRoom 오류:', error);
    next(error);
  }
};
