/// 일정 API 호출 및 Firebase Storage 일정 이미지 업로드.
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:travel_mate_app/data/models/itinerary_model.dart';

class ItineraryRemoteDataSource {
  final FirebaseStorage _firebaseStorage;
  final FirebaseAuth _firebaseAuth;
  final Dio _dio; // For making API calls to your Node.js backend

  ItineraryRemoteDataSource({
    FirebaseStorage? firebaseStorage,
    FirebaseAuth? firebaseAuth,
    Dio? dio,
  })  : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? Dio();

  // Upload itinerary image to Firebase Storage
  Future<String> uploadItineraryImage(String userId, File imageFile) async {
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

      final ref = _firebaseStorage.ref().child('itineraries/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
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

  // Get itineraries from backend API
  Future<List<ItineraryModel>> getItineraries() async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.get(
        'http://localhost:3000/api/itineraries', // Replace with your backend URL
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200) {
        return (response.data['itineraries'] as List)
            .map((json) => ItineraryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load itineraries: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to get itineraries: ${e.toString()}');
    }
  }

  // Get single itinerary from backend API
  Future<ItineraryModel> getItinerary(String itineraryId) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.get(
        'http://localhost:3000/api/itineraries/$itineraryId', // Replace with your backend URL
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200) {
        return ItineraryModel.fromJson(response.data['itinerary']);
      } else {
        throw Exception('Failed to load itinerary: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to get itinerary: ${e.toString()}');
    }
  }

  // Create itinerary in backend API
  Future<void> createItinerary(ItineraryModel itinerary) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.post(
        'http://localhost:3000/api/itineraries', // Replace with your backend URL
        data: itinerary.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create itinerary: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to create itinerary: ${e.toString()}');
    }
  }

  // Update itinerary in backend API
  Future<void> updateItinerary(ItineraryModel itinerary) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.patch(
        'http://localhost:3000/api/itineraries/${itinerary.id}', // Replace with your backend URL
        data: itinerary.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update itinerary: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to update itinerary: ${e.toString()}');
    }
  }

  // Delete itinerary in backend API
  Future<void> deleteItinerary(String itineraryId) async {
    try {
      final idToken = await _firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated.');
      }

      final response = await _dio.delete(
        'http://localhost:3000/api/itineraries/$itineraryId', // Replace with your backend URL
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete itinerary: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to delete itinerary: ${e.toString()}');
    }
  }
}
