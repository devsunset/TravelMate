/// 사용자 프로필 DTO(JSON 직렬화, fromJson/toJson)
import 'package:travel_mate_app/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.userId,
    required super.nickname,
    super.bio,
    super.profileImageUrl,
    super.gender,
    super.ageRange,
    super.travelStyles,
    super.interests,
    super.preferredDestinations,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      bio: json['bio'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      gender: json['gender'] as String?,
      ageRange: json['ageRange'] as String?,
      travelStyles: (json['travelStyles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      interests:
          (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      preferredDestinations:
          (json['preferredDestinations'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'gender': gender,
      'ageRange': ageRange,
      'travelStyles': travelStyles,
      'interests': interests,
      'preferredDestinations': preferredDestinations,
    };
  }

  @override
  UserProfileModel copyWith({
    String? userId,
    String? nickname,
    String? bio,
    String? profileImageUrl,
    String? gender,
    String? ageRange,
    List<String>? travelStyles,
    List<String>? interests,
    List<String>? preferredDestinations,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      travelStyles: travelStyles ?? this.travelStyles,
      interests: interests ?? this.interests,
      preferredDestinations: preferredDestinations ?? this.preferredDestinations,
    );
  }
}