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
  bool _isFilterExpanded = true; // 필터 확장 상태 추가

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
      _isFilterExpanded = false; // 검색 시작 시 필터 접기
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
            icon: Icon(_isFilterExpanded ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
            tooltip: '필터 접기/펴기',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchCompanions,
            tooltip: '검색',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          AnimatedCrossFade(
            duration: AppConstants.animationDuration,
            crossFadeState: _isFilterExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6, // 화면의 60%까지만 차지하도록 제한
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.value(context, compact: AppConstants.paddingSmall, medium: AppConstants.paddingMedium, expanded: AppConstants.paddingMedium),
                    vertical: AppConstants.paddingSmall,
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
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_search_rounded, color: AppColors.secondary, size: 20),
                                  const SizedBox(width: AppConstants.spacingSmall),
                                  Text(
                                    '사용자 프로필 기반 검색',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.spacingMedium),
                              
                              TextFormField(
                                controller: _preferredLocationController,
                                decoration: const InputDecoration(
                                  labelText: '선호 지역',
                                  prefixIcon: Icon(Icons.favorite_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              
                              TextFormField(
                                controller: _searchKeywordController,
                                decoration: const InputDecoration(
                                  labelText: '검색 키워드',
                                  prefixIcon: Icon(Icons.manage_search_rounded),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              // 성별 / 연령대 - 모바일에서 좁을 경우 줄바꿈되도록 Wrap 사용
                              Wrap(
                                spacing: AppConstants.spacingSmall,
                                runSpacing: AppConstants.spacingSmall,
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width - (AppConstants.paddingSmall * 4) - AppConstants.spacingSmall) / 2 > 140
                                        ? (MediaQuery.of(context).size.width - (AppConstants.paddingSmall * 6) - AppConstants.spacingSmall) / 2
                                        : double.infinity,
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedGender != null && _genders.contains(_selectedGender) ? _selectedGender : null,
                                      decoration: const InputDecoration(
                                        labelText: '성별',
                                        prefixIcon: Icon(Icons.people_alt_outlined),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      ),
                                      items: _genders.map((String gender) {
                                        return DropdownMenuItem<String>(
                                          value: gender,
                                          child: Text(gender, style: const TextStyle(fontSize: 13)),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() => _selectedGender = newValue);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width - (AppConstants.paddingSmall * 4) - AppConstants.spacingSmall) / 2 > 140
                                        ? (MediaQuery.of(context).size.width - (AppConstants.paddingSmall * 6) - AppConstants.spacingSmall) / 2
                                        : double.infinity,
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedAgeRange != null && _ageRanges.contains(_selectedAgeRange) ? _selectedAgeRange : null,
                                      decoration: const InputDecoration(
                                        labelText: '연령대',
                                        prefixIcon: Icon(Icons.cake_outlined),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      ),
                                      items: _ageRanges.map((String age) {
                                        return DropdownMenuItem<String>(
                                          value: age,
                                          child: Text(age, style: const TextStyle(fontSize: 13)),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() => _selectedAgeRange = newValue);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: AppConstants.spacingMedium),
                              // 여행 스타일 - 가로 스크롤
                              _buildHorizontalChips(
                                context,
                                '여행 스타일',
                                Icons.style_rounded,
                                AppColors.accent,
                                _availableTravelStyles,
                                _selectedTravelStyles,
                                (style, selected) {
                                  setState(() {
                                    if (selected) _selectedTravelStyles.add(style);
                                    else _selectedTravelStyles.remove(style);
                                  });
                                },
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              // 관심사 - 가로 스크롤
                              _buildHorizontalChips(
                                context,
                                '관심사',
                                Icons.favorite_rounded,
                                AppColors.error,
                                _availableInterests,
                                _selectedInterests,
                                (interest, selected) {
                                  setState(() {
                                    if (selected) _selectedInterests.add(interest);
                                    else _selectedInterests.remove(interest);
                                  });
                                },
                                activeColor: Colors.orangeAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      
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
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                                  const SizedBox(width: AppConstants.spacingSmall),
                                  Text(
                                    '일정 기반 검색',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              TextFormField(
                                controller: _destinationController,
                                decoration: const InputDecoration(
                                  labelText: '방문 목적지',
                                  prefixIcon: Icon(Icons.map_outlined),
                                ),
                              ),
                              const SizedBox(height: AppConstants.spacingSmall),
                              InkWell(
                                onTap: () => _selectDateRange(context),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: '여행 기간',
                                    prefixIcon: Icon(Icons.date_range_rounded),
                                    suffixIcon: Icon(Icons.chevron_right_rounded),
                                  ),
                                  child: Text(
                                    _startDate == null ? '기간 선택' : '${_startDate!.year}/${_startDate!.month}/${_startDate!.day} - ${_endDate!.year}/${_endDate!.month}/${_endDate!.day}',
                                    style: TextStyle(
                                      color: _startDate == null ? AppColors.textSecondary : AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _searchCompanions,
                          icon: const Icon(Icons.search),
                          label: const Text('동행 검색'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                    ],
                  ),
                ),
              ),
            ),
            secondChild: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.value(context, compact: AppConstants.paddingSmall, medium: AppConstants.paddingMedium, expanded: AppConstants.paddingMedium),
                vertical: AppConstants.paddingSmall,
              ),
              child: InkWell(
                onTap: () => setState(() => _isFilterExpanded = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _buildFilterSummary(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
                    ],
                  ),
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

  Widget _buildHorizontalChips(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    List<String> items,
    List<String> selectedItems,
    Function(String, bool) onSelected, {
    Color? activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12)),
            if (selectedItems.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text('${selectedItems.length}', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedItems.contains(item);
              return FilterChip(
                label: Text(item, style: const TextStyle(fontSize: 11)),
                selected: isSelected,
                onSelected: (selected) => onSelected(item, selected),
                selectedColor: (activeColor ?? color).withOpacity(0.25),
                checkmarkColor: activeColor ?? color,
                labelStyle: TextStyle(
                  color: isSelected ? (activeColor ?? color) : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              );
            },
          ),
        ),
      ],
    );
  }

  String _buildFilterSummary() {
    List<String> summaries = [];
    final loc = _preferredLocationController.text.trim();
    final dest = _destinationController.text.trim();
    final key = _searchKeywordController.text.trim();

    if (dest.isNotEmpty) summaries.add('목적지: $dest');
    else if (loc.isNotEmpty) summaries.add('선호: $loc');
    
    if (key.isNotEmpty) summaries.add('키워드: $key');
    if (_selectedGender != null && _selectedGender != '무관') summaries.add(_selectedGender!);
    if (_selectedAgeRange != null && _selectedAgeRange != '무관') summaries.add(_selectedAgeRange!);
    
    final stylesCount = _selectedTravelStyles.length;
    if (stylesCount > 0) summaries.add('스타일 $stylesCount');
    
    final interestsCount = _selectedInterests.length;
    if (interestsCount > 0) summaries.add('관심사 $interestsCount');

    if (summaries.isEmpty) return '모든 동행 검색 중 (필터 미설정)';
    return summaries.join(' • ');
  }
}
