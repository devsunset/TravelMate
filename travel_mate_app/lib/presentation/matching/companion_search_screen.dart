import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/app/responsive.dart';
import 'package:travel_mate_app/domain/entities/paginated_result.dart';
import 'package:travel_mate_app/domain/entities/user_profile.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';
import 'package:travel_mate_app/presentation/common/profile_avatar_widget.dart';
import 'package:travel_mate_app/domain/usecases/search_companions_usecase.dart';
import 'package:travel_mate_app/presentation/common/empty_state_widget.dart';

/// 동행 검색 화면.
///
/// [검색 조건]
/// - 목적지: preferredDestinations에 포함된 사용자 (서버: LIKE %목적지%)
/// - 검색어: 닉네임 또는 자기소개(bio)에 포함 (서버: LIKE %검색어%)
/// - 성별: 선택 시 일치만 (무관이면 조건 없음)
/// - 연령대: 선택 시 일치만 (무관이면 조건 없음)
/// - 여행 스타일/관심사: 선택한 항목을 가진 사용자만 (서버: Tag 또는 프로필 JSON 기준)
/// - 실제 요청 쿼리·결과는 디버그 로그([동행 검색] 요청 쿼리 / 응답) 및 백엔드 콘솔([동행 검색] 수신 쿼리 / 질의 조건 / 질의 결과)에서 확인 가능.
class CompanionSearchScreen extends StatefulWidget {
  const CompanionSearchScreen({super.key});

  @override
  State<CompanionSearchScreen> createState() => _CompanionSearchScreenState();
}

class _CompanionSearchScreenState extends State<CompanionSearchScreen> {
  static const int _pageSize = 20;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _preferredLocationController = TextEditingController(); // Added
  final TextEditingController _searchKeywordController = TextEditingController();
  final ScrollController _resultsScrollController = ScrollController();

  String? _selectedGender;
  String? _selectedAgeRange;
  final List<String> _selectedTravelStyles = [];
  final List<String> _selectedInterests = [];
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _noResults = false;
  List<UserProfile> _searchResults = [];
  int _total = 0;

  bool get _hasMore => _searchResults.length < _total;

  final List<String> _genders = ['남성', '여성', '무관'];
  final List<String> _ageRanges = ['10대', '20대', '30대', '40대', '50대 이상', '무관'];
  final List<String> _availableTravelStyles = ['모험', '휴양', '문화', '맛집', '저렴한 여행', '럭셔리', '혼자 여행', '그룹 여행'];
  final List<String> _availableInterests = ['자연', '역사', '예술', '해변', '산', '도시 탐험', '사진', '쇼핑', '나이트라이프', '웰니스'];

  @override
  void initState() {
    super.initState();
    _resultsScrollController.addListener(_onResultsScroll);
  }

  @override
  void dispose() {
    _resultsScrollController.removeListener(_onResultsScroll);
    _resultsScrollController.dispose();
    _destinationController.dispose();
    _preferredLocationController.dispose();
    _searchKeywordController.dispose();
    super.dispose();
  }

  void _onResultsScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading || _searchResults.isEmpty) return;
    final pos = _resultsScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadMoreCompanions();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years from now
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null && (picked.start != _startDate || picked.end != _endDate)) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _searchCompanions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _noResults = false;
      _searchResults = [];
      _total = 0;
    });

    try {
      final usecase = Provider.of<SearchCompanionsUsecase>(context, listen: false);
      final result = await _executeSearch(usecase, limit: _pageSize, offset: 0);

      if (mounted) {
        setState(() {
          _searchResults = result.items;
          _total = result.total;
          _isLoading = false;
          _noResults = result.items.isEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '동행 검색에 실패했습니다. 다시 시도해 주세요.';
          _isLoading = false;
          _noResults = false;
        });
      }
    }
  }

  Future<void> _loadMoreCompanions() async {
    if (!_hasMore || _isLoadingMore || _isLoading || _searchResults.isEmpty) return;
    setState(() => _isLoadingMore = true);

    try {
      final usecase = Provider.of<SearchCompanionsUsecase>(context, listen: false);
      final result = await _executeSearch(usecase, limit: _pageSize, offset: _searchResults.length);

      if (mounted) {
        final nextItems = result.items;
        setState(() {
          _searchResults = [..._searchResults, ...nextItems];
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<PaginatedResult<UserProfile>> _executeSearch(SearchCompanionsUsecase usecase, {required int limit, required int offset}) {
    final destination = _destinationController.text.trim();
    final preferredLocation = _preferredLocationController.text.trim(); // Added
    final keyword = _searchKeywordController.text.trim();
    final gender = _selectedGender != null && _selectedGender != '무관' ? _selectedGender : null;
    final ageRange = _selectedAgeRange != null && _selectedAgeRange != '무관' ? _selectedAgeRange : null;
    final travelStyles = _selectedTravelStyles.isEmpty ? null : List<String>.from(_selectedTravelStyles);
    final interests = _selectedInterests.isEmpty ? null : List<String>.from(_selectedInterests);
    return usecase.execute(
      destination: destination.isEmpty ? null : destination,
      preferredLocation: preferredLocation.isEmpty ? null : preferredLocation, // Added
      keyword: keyword.isEmpty ? null : keyword,
      gender: gender,
      ageRange: ageRange,
      travelStyles: travelStyles,
      interests: interests,
      startDate: _startDate?.toIso8601String(),
      endDate: _endDate?.toIso8601String(),
      limit: limit,
      offset: offset,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom color for better card contrast in dark mode
    final cardBgColor = const Color(0xFF1E1E2E); 
    
    return Scaffold(
      appBar: AppAppBar(
        title: '동행 찾기',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchCompanions,
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3, // Allow filters to take up space but scroll if needed
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.value(context, compact: AppConstants.paddingSmall, medium: AppConstants.paddingMedium, expanded: AppConstants.paddingMedium),
                  vertical: AppConstants.paddingMedium,
                ),
                child: Column(
                  children: [
                    // SECTION 1: Profile-based Search
                    Card(
                      elevation: 4,
                      color: cardBgColor,
                      shadowColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.secondary.withOpacity(0.3), width: 1.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium + 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.person_search_rounded, color: AppColors.secondary, size: 22),
                                ),
                                const SizedBox(width: AppConstants.spacingSmall + 4),
                                Text(
                                  '사용자 프로필 기반 검색',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1, thickness: 0.8, color: AppColors.border),
                            ),
                            
                            // Preferred Location
                            TextFormField(
                              controller: _preferredLocationController,
                              decoration: const InputDecoration(
                                labelText: '선호 지역',
                                hintText: '평소 관심 있는 지역 또는 국가',
                                prefixIcon: Icon(Icons.favorite_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),
                            
                            TextFormField(
                              controller: _searchKeywordController,
                              decoration: const InputDecoration(
                                labelText: '검색 키워드',
                                hintText: '닉네임 또는 소개글 키워드',
                                prefixIcon: Icon(Icons.manage_search_rounded),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedGender != null && _genders.contains(_selectedGender) ? _selectedGender : null,
                                    decoration: const InputDecoration(
                                      labelText: '성별',
                                      prefixIcon: Icon(Icons.wc_rounded),
                                    ),
                                    items: _genders.map((String gender) {
                                      return DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(gender),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() => _selectedGender = newValue);
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacingMedium),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedAgeRange != null && _ageRanges.contains(_selectedAgeRange) ? _selectedAgeRange : null,
                                    decoration: const InputDecoration(
                                      labelText: '연령대',
                                      prefixIcon: Icon(Icons.history_toggle_off_rounded),
                                    ),
                                    items: _ageRanges.map((String age) {
                                      return DropdownMenuItem<String>(
                                        value: age,
                                        child: Text(age),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() => _selectedAgeRange = newValue);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: AppConstants.spacingLarge),
                            Row(
                              children: [
                                const Icon(Icons.style_rounded, color: AppColors.accent, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '여행 스타일',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: AppConstants.spacingSmall,
                              runSpacing: AppConstants.spacingSmall,
                              children: _availableTravelStyles.map((style) {
                                final isSelected = _selectedTravelStyles.contains(style);
                                return FilterChip(
                                  label: Text(style, style: const TextStyle(fontSize: 12)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedTravelStyles.add(style);
                                      } else {
                                        _selectedTravelStyles.remove(style);
                                      }
                                    });
                                  },
                                  selectedColor: AppColors.accent.withOpacity(0.25),
                                  checkmarkColor: AppColors.accent,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.accent : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: AppConstants.spacingLarge),
                            Row(
                              children: [
                                const Icon(Icons.favorite_rounded, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '관심사',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: AppConstants.spacingSmall,
                              runSpacing: AppConstants.spacingSmall,
                              children: _availableInterests.map((interest) {
                                final isSelected = _selectedInterests.contains(interest);
                                return FilterChip(
                                  label: Text(interest, style: const TextStyle(fontSize: 12)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedInterests.add(interest);
                                      } else {
                                        _selectedInterests.remove(interest);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.orange.withOpacity(0.2),
                                  checkmarkColor: Colors.orangeAccent,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.orangeAccent : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge + 8),
                    
                    // SECTION 2: Schedule-based Search
                    Card(
                      elevation: 4,
                      color: cardBgColor,
                      shadowColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium + 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 22),
                                ),
                                const SizedBox(width: AppConstants.spacingSmall + 4),
                                Text(
                                  '일정 기반 검색',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1, thickness: 0.8, color: AppColors.border),
                            ),
                            TextFormField(
                              controller: _destinationController,
                              decoration: const InputDecoration(
                                labelText: '방문 목적지',
                                hintText: '예: 파리, 도쿄, 뉴욕',
                                prefixIcon: Icon(Icons.map_outlined),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingMedium),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                title: Text(
                                  _startDate == null && _endDate == null
                                      ? '여행 예정 기간 선택'
                                      : '${_startDate!.year}/${_startDate!.month}/${_startDate!.day} - ${_endDate!.year}/${_endDate!.month}/${_endDate!.day}',
                                  style: TextStyle(
                                    color: _startDate == null ? AppColors.textSecondary : AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: _startDate == null ? FontWeight.normal : FontWeight.w500,
                                  ),
                                ),
                                leading: const Icon(Icons.date_range_rounded, color: AppColors.primary),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => _selectDateRange(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge + 16),
                    
                    // Search Action Button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _searchCompanions,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('조건으로 동행 찾기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _noResults
                    ? EmptyStateWidget(
                        icon: Icons.person_search_rounded,
                        title: '검색 조건에 맞는 동행이 없어요',
                        subtitle: '조건을 바꿔 보시거나 잠시 후 다시 검색해 보세요.',
                      )
                    : _errorMessage != null
                        ? EmptyStateWidget(
                            icon: Icons.cloud_off_rounded,
                            title: _errorMessage!,
                            isError: true,
                            onRetry: _searchCompanions,
                          )
                        : _searchResults.isEmpty
                            ? EmptyStateWidget(
                                icon: Icons.search_rounded,
                                title: '동행을 검색해 보세요',
                                subtitle: '목적지, 성별, 연령대 등을 선택한 뒤 검색 버튼을 눌러 주세요.',
                              )
                            : ListView.builder(
                                controller: _resultsScrollController,
                                itemCount: _searchResults.length + (_hasMore && _isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _searchResults.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  final user = _searchResults[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: Responsive.value(context, compact: AppConstants.paddingSmall, medium: AppConstants.paddingMedium, expanded: AppConstants.paddingMedium),
                                      vertical: AppConstants.paddingSmall,
                                    ),
                                    elevation: 1,
                                    child: ListTile(
                                      leading: ProfileAvatar(profileImageUrl: user.profileImageUrl, gender: user.gender, radius: 20),
                                      title: Text(user.nickname),
                                      subtitle: Text('${user.gender ?? ''} ${user.ageRange ?? ''}\n${user.bio ?? ''}'.trim()),
                                      isThreeLine: true,
                                      onTap: () {
                                        if (user.userId.isNotEmpty) {
                                          context.push('/users/${Uri.encodeComponent(user.userId)}');
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}
