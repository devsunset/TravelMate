/// 채팅 메시지 DTO. Firestore 문서·[ChatMessage] 엔티티 변환.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_mate_app/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.content,
    required super.sentAt,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ChatMessageModel(
      id: snapshot.id,
      senderId: data?['senderId'] as String,
      receiverId: data?['receiverId'] as String,
      content: data?['content'] as String,
      sentAt: (data?['sentAt'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      content: entity.content,
      sentAt: entity.sentAt,
    );
  }
}
