/// 1:1 쪽지 API 호출(백엔드 /api/messages).
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageRemoteDataSource {
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  MessageRemoteDataSource({Dio? dio, FirebaseAuth? firebaseAuth})
      : _dio = dio ?? Dio(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> sendPrivateMessage({
    required String receiverId,
    required String content,
  }) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.post(
        'http://localhost:3000/api/messages/private', // Replace with your backend URL
        data: {
          'receiverId': receiverId,
          'content': content,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message: ${response.data}');
      }
    } on DioError catch (e) {
      throw Exception('Failed to send message: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }
}
