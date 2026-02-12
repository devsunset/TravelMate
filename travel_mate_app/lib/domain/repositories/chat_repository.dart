/// 채팅 메시지 스트림·발송 추상 레포지토리.
import 'package:travel_mate_app/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> getChatMessages(String chatRoomId);
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
  });
}
