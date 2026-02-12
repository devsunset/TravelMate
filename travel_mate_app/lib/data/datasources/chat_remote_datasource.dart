/// Firestore 기반 채팅 메시지 조회·발송.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_mate_app/domain/entities/chat_message.dart';
import 'package:travel_mate_app/data/models/chat_message_model.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  ChatRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || currentUser.uid != senderId) {
        throw Exception('Unauthorized message send attempt.');
      }

      final message = ChatMessageModel(
        id: '', // Firestore will generate this
        senderId: senderId,
        receiverId: receiverId, // In a 1:1 chat, this is the other user's ID
        content: content,
        sentAt: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .withConverter<ChatMessage>(
          fromFirestore: ChatMessage.fromFirestore,
          toFirestore: (ChatMessage msg, _) => (msg as ChatMessageModel).toFirestore(), // Need ChatMessageModel.toFirestore
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Future<void> markMessageAsRead(String chatRoomId, String messageId) async {
  //   // Implement logic to mark messages as read if needed
  // }
}
