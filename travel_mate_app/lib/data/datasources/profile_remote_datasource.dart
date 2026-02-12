/// 프로필 API 호출 및 Firebase Storage 프로필 이미지 업로드.
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:travel_mate_app/data/models/user_profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseStorage _firebaseStorage;
  final FirebaseAuth _firebaseAuth;
  final Dio _dio; // For making API calls to your Node.js backend

  ProfileRemoteDataSource({
    FirebaseStorage? firebaseStorage,
    FirebaseAuth? firebaseAuth,
    Dio? dio,
  })  : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? Dio();

  // Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Compress image before uploading
      // Example from implementation guide ig-005-image-optimization
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

      final ref = _firebaseStorage.ref().child('users/$userId/profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
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

  // Get user profile from backend API
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.get(
        'http://localhost:3000/api/users/$userId/profile', // Replace with your backend URL
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data['userProfile']);
      } else {
        throw Exception('Failed to load user profile: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  // Create user profile in backend API
  Future<void> createUserProfile(UserProfileModel userProfile) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.post(
        'http://localhost:3000/api/users/${userProfile.userId}/profile', // Replace with your backend URL
        data: userProfile.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create user profile: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  // Update user profile in backend API
  Future<void> updateUserProfile(UserProfileModel userProfile) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.patch(
        'http://localhost:3000/api/users/${userProfile.userId}/profile', // Replace with your backend URL
        data: userProfile.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user profile: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Delete user profile in backend API
  Future<void> deleteUserProfile(String userId) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.delete(
        'http://localhost:3000/api/users/$userId/profile', // Replace with your backend URL
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete user profile: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to delete user profile: ${e.toString()}');
    }
  }
}