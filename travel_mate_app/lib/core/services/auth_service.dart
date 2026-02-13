/// Firebase Auth 기반 로그인(이메일/비밀번호, Google), ID 토큰 로컬 저장.
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Keep this for now in case other parts use it
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travel_mate_app/app/constants.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = kIsWeb && AppConstants.googleSignInWebClientId != null
      ? GoogleSignIn(clientId: AppConstants.googleSignInWebClientId)
      : GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// 인증 상태 스트림(로그인/로그아웃 시 갱신).
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  /// Firebase ID 토큰을 보안 저장소에 저장 또는 삭제.
  Future<void> _storeIdToken(String? token) async {
    if (token != null) {
      await _secureStorage.write(key: 'firebase_id_token', value: token);
    } else {
      await _secureStorage.delete(key: 'firebase_id_token');
    }
  }

  /// 보안 저장소에 저장된 Firebase ID 토큰 조회.
  Future<String?> getIdToken() async {
    return await _secureStorage.read(key: 'firebase_id_token');
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
