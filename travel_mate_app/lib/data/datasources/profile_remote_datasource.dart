/// 프로필 API 호출 및 백엔드 프로필 이미지 업로드.
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/data/models/user_profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  ProfileRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    Dio? dio,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? Dio();

  /// 프로필 이미지를 백엔드에 업로드하고 반환된 imageUrl을 전달합니다.
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
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

      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated.');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(compressedImage.path, filename: 'image.jpg'),
      });

      final response = await _dio.post(
        '${AppConstants.apiBaseUrl}/api/upload/profile',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200 && response.data['imageUrl'] != null) {
        return response.data['imageUrl'] as String;
      }
      throw Exception('Failed to upload image: ${response.data}');
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
        '${AppConstants.apiBaseUrl}/api/users/$userId/profile', // Replace with your backend URL
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
        '${AppConstants.apiBaseUrl}/api/users/${userProfile.userId}/profile',
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
        '${AppConstants.apiBaseUrl}/api/users/${userProfile.userId}/profile',
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
        '${AppConstants.apiBaseUrl}/api/users/$userId/profile', // Replace with your backend URL
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