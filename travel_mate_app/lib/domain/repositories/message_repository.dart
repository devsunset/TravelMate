/// 1:1 쪽지 발송 추상 레포지토리.
import 'package:travel_mate_app/domain/entities/private_message.dart';

abstract class MessageRepository {
  Future<void> sendPrivateMessage({
    required String receiverId,
    required String content,
  });
  // TODO: Add methods for getting messages, marking as read, etc.
}