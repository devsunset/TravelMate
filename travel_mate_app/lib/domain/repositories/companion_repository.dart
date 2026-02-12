/// 동행 검색 추상 레포지토리
import 'package:travel_mate_app/data/models/user_profile_model.dart';

abstract class CompanionRepository {
  Future<List<UserProfile>> searchCompanions({
    String? destination,
    List<String>? interestTags,
    DateTime? startDate,
    DateTime? endDate,
    String? gender,
    String? ageRange,
  });
}