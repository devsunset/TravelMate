/// FCM 권한 요청, 토큰 발급/갱신, 백엔드에 토큰 전송, 포그라운드/백그라운드 메시지 수신 처리.
import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class FcmService {
  final FirebaseMessaging _firebaseMessaging;
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  FcmService({FirebaseMessaging? firebaseMessaging, FirebaseAuth? firebaseAuth, Dio? dio})
      : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? Dio();

  /// 알림 권한 요청, FCM 토큰 획득·갱신, 백엔드 전송, 포그라운드/백그라운드 메시지 리스너 등록.
  Future<void> initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM: 알림 권한 허용됨');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('FCM: 임시 알림 권한 허용됨');
    } else {
      print('FCM: 알림 권한 거부 또는 미응답');
      return;
    }

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _sendFcmTokenToBackend(token);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await _sendFcmTokenToBackend(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM: 포그라운드 메시지 수신: ${message.data}');
      if (message.notification != null) {
        print('FCM: 알림: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('FCM: 알림 탭으로 앱 열림: ${message.data}');
    });
  }

  /// FCM 토큰을 백엔드 /api/fcm/token 에 전송.
  Future<void> _sendFcmTokenToBackend(String token) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      print('FCM: 로그인되지 않아 토큰 전송 생략.');
      return;
    }

    try {
      final idToken = await currentUser.getIdToken();
      if (idToken == null) {
        throw Exception('Firebase ID 토큰이 없습니다.');
      }

      String deviceType = 'unknown';
      if (kIsWeb) {
        deviceType = 'web';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        deviceType = 'android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        deviceType = 'ios';
      }

      await _dio.post(
        '${AppConstants.apiBaseUrl}/api/fcm/token',
        data: {
          'token': token,
          'deviceType': deviceType,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );
      print('FCM 토큰 백엔드 전송 완료.');
    } on DioException catch (e) {
      developer.log('FCM 토큰 전송 실패: ${e.response?.data ?? e.message}', name: 'FCM', level: 1000);
    } catch (e) {
      developer.log('FCM 토큰 전송 오류: $e', name: 'FCM', level: 1000);
    }
  }
}