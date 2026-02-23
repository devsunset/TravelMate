/// 채팅방 목록 스트림 조회 유스케이스.
import 'package:travel_mate_app/domain/entities/chat_room_info.dart';
import 'package:travel_mate_app/domain/repositories/chat_repository.dart';

class GetChatRooms {
  final ChatRepository repository;

  GetChatRooms(this.repository);

  Stream<List<ChatRoomInfo>> execute(String currentUserId) {
    return repository.getChatRooms(currentUserId);
  }
}
