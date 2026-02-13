/// Firebase Auth 기반 로그인(이메일/비밀번호, Google), ID 토큰 로컬 저장.
/// 웹에서는 SharedPreferences, 모바일에서는 FlutterSecureStorage 사용(웹에서 secure_storage 미지원/오류 방지).
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travel_mate_app/app/constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = kIsWeb && AppConstants.googleSignInWebClientId != null && AppConstants.googleSignInWebClientId!.isNotEmpty
      ? GoogleSignIn(clientId: AppConstants.googleSignInWebClientId)
      : GoogleSignIn();
  static const String _tokenKey = 'firebase_id_token';

  /// 인증 상태 스트림(로그인/로그아웃 시 갱신).
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  /// 토큰 저장(실패해도 예외 전파하지 않음 — 로그인 성공을 깨지 않도록).
  Future<void> _storeIdToken(String? token) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString(_tokenKey, token);
        } else {
          await prefs.remove(_tokenKey);
        }
      } else {
        const storage = FlutterSecureStorage();
        if (token != null) {
          await storage.write(key: _tokenKey, value: token);
        } else {
          await storage.delete(key: _tokenKey);
        }
      }
    } catch (e) {
      developer.log('Token storage failed (non-fatal): $e', name: 'Auth', level: 1000);
    }
  }

  /// 저장된 Firebase ID 토큰 조회. 없으면 Firebase 현재 유저에서 갱신 시도.
  Future<String?> getIdToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString(_tokenKey);
        if (stored != null && stored.isNotEmpty) return stored;
      } else {
        const storage = FlutterSecureStorage();
        final stored = await storage.read(key: _tokenKey);
        if (stored != null && stored.isNotEmpty) return stored;
      }
      final token = await _firebaseAuth.currentUser?.getIdToken();
      if (token != null) await _storeIdToken(token);
      return token;
    } catch (e) {
      developer.log('getIdToken failed: $e', name: 'Auth', level: 1000);
      return _firebaseAuth.currentUser?.getIdToken();
    }
  }

  /// 이메일·비밀번호 로그인. 실패 시 null.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      await _storeIdToken(await result.user?.getIdToken());
      return result.user;
    } catch (e) {
      developer.log(e.toString(), name: 'Auth', level: 1000);
      await _storeIdToken(null);
      return null;
    }
  }

  /// 이메일·비밀번호로 회원가입 후 토큰 저장.
  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _storeIdToken(await result.user?.getIdToken());
      return result.user;
    } catch (e) {
      developer.log(e.toString(), name: 'Auth', level: 1000);
      await _storeIdToken(null);
      return null;
    }
  }

  /// Google 로그인. 취소 또는 실패 시 null.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _firebaseAuth.signInWithCredential(credential);
      await _storeIdToken(await result.user?.getIdToken());
      return result.user;
    } catch (e) {
      developer.log(e.toString(), name: 'Auth', level: 1000);
      await _storeIdToken(null);
      return null;
    }
  }

  /// 로그아웃. Firebase·Google 로그아웃 및 저장된 토큰 삭제.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await _storeIdToken(null);
    } catch (e) {
      developer.log(e.toString(), name: 'Auth', level: 1000);
    }
  }

  /// 비밀번호 재설정 이메일 전송.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      developer.log(e.toString(), name: 'Auth', level: 1000);
      rethrow; // 재설정 이메일 실패 시 에러를 다시 던져 UI에서 처리할 수 있도록 함
    }
  }
}
