/// 게시글 API 호출 및 Firebase Storage 이미지 업로드
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:travel_mate_app/data/models/post_model.dart';

class PostRemoteDataSource {
  final FirebaseStorage _firebaseStorage;
  final FirebaseAuth _firebaseAuth;
  final Dio _dio; // For making API calls to your Node.js backend

  PostRemoteDataSource({
    FirebaseStorage? firebaseStorage,
    FirebaseAuth? firebaseAuth,
    Dio? dio,
  })  : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? Dio();

  // Upload post image to Firebase Storage
  Future<String> uploadPostImage(String userId, File imageFile) async {
    try {
      // Compress image before uploading
      final filePath = imageFile.absolute.path;
      final targetPath = '${filePath}_compressed.jpg';

      final XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedImage == null) {
        throw Exception('Image compression failed');
      }

      final ref = _firebaseStorage.ref().child('posts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(File(compressedImage.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Get posts from backend API
  Future<List<PostModel>> getPosts() async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.get(
        'http://localhost:3000/api/posts', // Replace with your backend URL
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200) {
        return (response.data['posts'] as List)
            .map((json) => PostModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load posts: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to get posts: ${e.toString()}');
    }
  }

  // Get single post from backend API
  Future<PostModel> getPost(String postId) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.get(
        'http://localhost:3000/api/posts/$postId', // Replace with your backend URL
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(response.data['post']);
      } else {
        throw Exception('Failed to load post: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to get post: ${e.toString()}');
    }
  }

  // Create post in backend API
  Future<void> createPost(PostModel post) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.post(
        'http://localhost:3000/api/posts', // Replace with your backend URL
        data: post.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create post: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  // Update post in backend API
  Future<void> updatePost(PostModel post) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.patch(
        'http://localhost:3000/api/posts/${post.id}', // Replace with your backend URL
        data: post.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update post: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to update post: ${e.toString()}');
    }
  }

  // Delete post in backend API
  Future<void> deletePost(String postId) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.delete(
        'http://localhost:3000/api/posts/$postId', // Replace with your backend URL
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete post: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to delete post: ${e.toString()}');
    }
  }
}
