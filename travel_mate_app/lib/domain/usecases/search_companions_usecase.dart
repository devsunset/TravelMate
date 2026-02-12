/// 동행 검색 유스케이스
import 'package:travel_mate_app/domain/entities/user_profile.dart';
import 'package:travel_mate_app/domain/repositories/companion_repository.dart';

class SearchCompanionsUsecase {
  final CompanionRepository _repository;

  SearchCompanionsUsecase(this._repository);

  Future<List<UserProfile>> execute({
    String? destination,
    List<String>? interestTags,
    DateTime? startDate,
    DateTime? endDate,
    String? gender,
    String? ageRange,
  }) async {
    return _repository.searchCompanions(
      destination: destination,
      interestTags: interestTags,
      startDate: startDate,
      endDate: endDate,
      gender: gender,
      ageRange: ageRange,
    );
  }
}
