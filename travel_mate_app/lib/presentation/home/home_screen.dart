import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:google_fonts/google_fonts.dart';
/// 로그인 후 홈 화면. 히어로 + 기능 카드 + 탐색 버튼 (Travel-Companion-Finder 스타일).
/// 뷰포트 높이에 맞춰 반응형으로 간격·폰트·그리드 크기 조정.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final profileUserId = currentUser != null
        ? (currentUser.email?.isNotEmpty == true ? Uri.encodeComponent(currentUser.email!) : currentUser.uid)
        : null;
    final h = MediaQuery.sizeOf(context).height;
    final isCompact = h < 680;
    final isMedium = h >= 680 && h < 820;

    // 반응형 값: 작은 화면일수록 여백·폰트·버튼 높이 축소
    final headerPaddingV = isCompact ? 6.0 : (isMedium ? 10.0 : AppConstants.paddingMedium);
    final heroTop = isCompact ? 8.0 : (isMedium ? 14.0 : 24.0);
    final badgePaddingH = isCompact ? 10.0 : 14.0;
    final badgePaddingV = isCompact ? 5.0 : 8.0;
    final badgeFontSize = isCompact ? 11.0 : 12.0;
    final heroTitleSize = isCompact ? 26.0 : (isMedium ? 30.0 : 36.0);
    final heroSubtitleSize = isCompact ? 12.0 : (isMedium ? 13.0 : 15.0);
    final heroAfterTitle = isCompact ? 6.0 : 12.0;
    final heroBottom = isCompact ? 12.0 : (isMedium ? 18.0 : 24.0);
    final gridSpacing = isCompact ? 8.0 : 10.0;
    final bottomPadding = isCompact ? 24.0 : 32.0;

    final navCards = [
      (Icons.person_search_rounded, '동행 찾기', AppColors.secondary, () => context.go('/matching/search')),
      (Icons.chat_bubble_outline_rounded, '채팅', AppColors.primary, () => context.go('/chat')),
      (Icons.article_outlined, '커뮤니티', AppColors.accent, () => context.go('/community')),
      (Icons.calendar_month_rounded, '일정', AppColors.secondary, () => context.go('/itinerary')),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.background,
              AppColors.background.withOpacity(0.98),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: headerPaddingV),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isCompact ? 8 : 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.explore, color: Colors.white, size: isCompact ? 20 : 24),
                        ),
                        SizedBox(width: isCompact ? 8 : 10),
                        Text('TravelMate', style: GoogleFonts.outfit(fontSize: isCompact ? 18 : 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.person_outline, color: AppColors.textPrimary, size: isCompact ? 22 : 24),
                          onPressed: () {
                            if (profileUserId != null) context.go('/users/$profileUserId');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: isCompact ? 22 : 24),
                          onPressed: () => context.go('/settings/account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: heroTop),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                      ),
                      child: Text('Explore the world together', style: GoogleFonts.plusJakartaSans(fontSize: badgeFontSize, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                    ),
                    SizedBox(height: isCompact ? 8 : 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text('Find Your\nTravel Squad', style: GoogleFonts.outfit(fontSize: heroTitleSize, fontWeight: FontWeight.bold, height: 1.15, color: Colors.white)),
                    ),
                    SizedBox(height: heroAfterTitle),
                    Text('같은 취향의 여행자와 만나고, 일정을 공유하고, 추억을 나눠보세요.', style: GoogleFonts.plusJakartaSans(fontSize: heroSubtitleSize, color: AppColors.textSecondary, height: 1.4)),
                    SizedBox(height: heroBottom),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight - bottomPadding;
                    final w = MediaQuery.sizeOf(context).width;
                    final pad = AppConstants.paddingLarge;
                    final cellWidth = (w - 2 * pad - gridSpacing) / 2;
                    final rowHeight = (availableHeight - gridSpacing) / 2;
                    final aspectRatio = cellWidth / rowHeight.clamp(40.0, double.infinity);
                    return Padding(
                      padding: EdgeInsets.only(left: pad, right: pad, bottom: bottomPadding),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: gridSpacing,
                          crossAxisSpacing: gridSpacing,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final item = navCards[index];
                          return _NavCard(icon: item.$1, label: item.$2, color: item.$3, onTap: item.$4, compact: isCompact);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _NavCard({required this.icon, required this.label, required this.color, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 10.0 : 14.0;
    final iconWrap = compact ? 14.0 : 18.0;
    final iconSize = compact ? 30.0 : 38.0;
    final gap = compact ? 6.0 : 10.0;
    final fontSize = compact ? 12.0 : 14.0;
    // 밝은 톤: 배경보다 확실히 밝게 + 테마색 틴트로 구분
    const cardSurfaceLight = Color(0xFF28284A);
    const cardSurfaceLighter = Color(0xFF32325C);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding + 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.65), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.22),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardSurfaceLight,
                cardSurfaceLighter,
                color.withOpacity(0.18),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(iconWrap),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.5),
                      color.withOpacity(0.28),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 14,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: iconSize),
              ),
              SizedBox(height: gap),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: fontSize, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
