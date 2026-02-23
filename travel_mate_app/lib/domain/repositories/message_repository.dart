/// 1:1 쪽지 발송 추상 레포지토리.
abstract class MessageRepository {
  Future<void> sendPrivateMessage({
    required String receiverId,
    required String content,
  });
  // TODO: Add methods for getting messages, marking as read, etc.
}