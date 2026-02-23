/// 채팅방 목록용 엔티티(채팅방 ID, 상대 ID, 마지막 메시지·시각).
import 'package:equatable/equatable.dart';

class ChatRoomInfo extends Equatable {
  final String chatRoomId;
  final String otherParticipantId;
  final String lastMessage;
  final DateTime lastMessageAt;

  const ChatRoomInfo({
    required this.chatRoomId,
    required this.otherParticipantId,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  @override
  List<Object?> get props => [chatRoomId, otherParticipantId, lastMessage, lastMessageAt];
}
