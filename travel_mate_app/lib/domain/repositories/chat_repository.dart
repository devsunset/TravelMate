/// 채팅 메시지 스트림·발송·채팅방 목록 추상 레포지토리.
import 'package:travel_mate_app/domain/entities/chat_message.dart';
import 'package:travel_mate_app/domain/entities/chat_room_info.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> getChatMessages(String chatRoomId);
  Stream<List<ChatRoomInfo>> getChatRooms(String currentUserId);
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
  });
}
