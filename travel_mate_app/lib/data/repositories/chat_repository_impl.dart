/// 채팅 레포지토리 구현. Firestore 데이터소스 위임.
import 'package:travel_mate_app/data/datasources/chat_remote_datasource.dart';
import 'package:travel_mate_app/domain/entities/chat_message.dart';
import 'package:travel_mate_app/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return remoteDataSource.getChatMessages(chatRoomId);
  }

  @override
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    return await remoteDataSource.sendMessage(
      chatRoomId: chatRoomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );
  }
}
