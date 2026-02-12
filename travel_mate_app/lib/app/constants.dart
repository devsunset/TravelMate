/// 앱 전역 상수(패딩, 간격, 테두리 반경, 앱명, 비밀번호/OTP 규칙, 애니메이션 시간).
class AppConstants {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double borderRadius = 12.0;

  static const String appName = "TravelMate";
  static const int passwordMinLength = 6;
  static const int otpLength = 6;
  static const Duration animationDuration = Duration(milliseconds: 300);
}
