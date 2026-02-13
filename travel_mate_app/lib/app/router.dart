/// GoRouter 설정. 로그인 여부에 따라 보호 경로 리다이렉트, 홈/로그인/프로필/채팅/커뮤니티/신고 등 경로 정의.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_mate_app/presentation/auth/login_screen.dart';
import 'package:travel_mate_app/presentation/auth/signup_screen.dart';
import 'package:travel_mate_app/presentation/profile/profile_edit_screen.dart';
import 'package:travel_mate_app/presentation/settings/account_settings_screen.dart';
import 'package:travel_mate_app/presentation/matching/companion_search_screen.dart';
import 'package:travel_mate_app/presentation/profile/user_profile_screen.dart';
import 'package:travel_mate_app/presentation/chat/chat_list_screen.dart';
import 'package:travel_mate_app/presentation/chat/chat_room_screen.dart';
import 'package:travel_mate_app/presentation/community/community_screen.dart';
import 'package:travel_mate_app/presentation/community/post_detail_screen.dart';
import 'package:travel_mate_app/presentation/community/post_write_screen.dart';
import 'package:travel_mate_app/presentation/common/report_submission_screen.dart';
import 'package:travel_mate_app/presentation/common/report_button_widget.dart';
import 'package:travel_mate_app/presentation/itinerary/itinerary_list_screen.dart';
import 'package:travel_mate_app/presentation/itinerary/itinerary_detail_screen.dart';
import 'package:travel_mate_app/presentation/itinerary/itinerary_write_screen.dart';
import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:google_fonts/google_fonts.dart';

/// 로그인 후 홈 화면. 히어로 + 기능 카드 + 탐색 버튼 (Travel-Companion-Finder 스타일).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.explore, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 10),
                          Text('TripMate', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
                            onPressed: () {
                              if (currentUserUid != null) context.go('/users/$currentUserUid');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                            onPressed: () => context.go('/settings/account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        child: Text('Explore the world together', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text('Find Your\nTravel Squad', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, height: 1.15, color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                      Text('같은 취향의 여행자와 만나고, 일정을 공유하고, 추억을 나눠보세요.', style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textSecondary, height: 1.4)),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => context.go('/community'),
                              icon: const Icon(Icons.public, size: 20),
                              label: const Text('커뮤니티'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/itinerary'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: const Text('일정 탐색'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: Text('바로가기', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildListDelegate([
                    _NavCard(icon: Icons.search, label: '동행 찾기', color: AppColors.secondary, onTap: () => context.go('/matching/search')),
                    _NavCard(icon: Icons.chat_bubble_outline, label: '채팅', color: AppColors.primary, onTap: () => context.go('/chat')),
                    _NavCard(icon: Icons.article_outlined, label: '커뮤니티', color: AppColors.accent, onTap: () => context.go('/community')),
                    _NavCard(icon: Icons.calendar_month, label: '일정', color: AppColors.secondary, onTap: () => context.go('/itinerary')),
                  ]),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('로그아웃'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
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

  const _NavCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.8),
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(User? user) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignupScreen();
        },
      ),
      GoRoute(
        path: '/profile',
        redirect: (BuildContext context, GoRouterState state) {
          final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
          if (currentUserUid != null) return '/users/$currentUserUid';
          return '/login';
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileEditScreen();
        },
      ),
      GoRoute(
        path: '/settings/account',
        builder: (BuildContext context, GoRouterState state) {
          return const AccountSettingsScreen();
        },
      ),
      GoRoute(
        path: '/matching/search',
        builder: (BuildContext context, GoRouterState state) {
          return const CompanionSearchScreen();
        },
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (BuildContext context, GoRouterState state) {
          final userId = state.pathParameters['userId']!;
          return UserProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (BuildContext context, GoRouterState state) {
          return const ChatListScreen();
        },
      ),
      GoRoute(
        path: '/chat/room/:chatRoomId',
        builder: (BuildContext context, GoRouterState state) {
          final chatRoomId = state.pathParameters['chatRoomId']!;
          final receiverNickname = state.extra as String?;
          return ChatRoomScreen(chatRoomId: chatRoomId, receiverNickname: receiverNickname);
        },
      ),
      GoRoute(
        path: '/community',
        builder: (BuildContext context, GoRouterState state) {
          return const CommunityScreen();
        },
      ),
      GoRoute(
        path: '/community/post/new',
        builder: (BuildContext context, GoRouterState state) {
          return const PostWriteScreen();
        },
      ),
      GoRoute(
        path: '/community/post/:postId',
        builder: (BuildContext context, GoRouterState state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/community/post/:postId/edit',
        builder: (BuildContext context, GoRouterState state) {
          final postId = state.pathParameters['postId']!;
          return PostWriteScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/report',
        builder: (BuildContext context, GoRouterState state) {
          final args = state.extra as Map<String, dynamic>;
          return ReportSubmissionScreen(
            entityType: args['entityType'] as ReportEntityType,
            entityId: args['entityId'] as String,
            reporterUserId: args['reporterUserId'] as String,
          );
        },
      ),
      GoRoute(
        path: '/itinerary',
        builder: (_, __) => const ItineraryListScreen(),
      ),
      GoRoute(
        path: '/itinerary/new',
        builder: (_, __) => const ItineraryWriteScreen(itineraryId: null),
      ),
      GoRoute(
        path: '/itinerary/:itineraryId',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['itineraryId']!;
          return ItineraryDetailScreen(itineraryId: id);
        },
      ),
      GoRoute(
        path: '/itinerary/:itineraryId/edit',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['itineraryId']!;
          return ItineraryWriteScreen(itineraryId: id);
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = user != null;

      final bool tryingToAccessProtected =
          state.matchedLocation == '/' ||
          state.matchedLocation.startsWith('/profile') ||
          state.matchedLocation.startsWith('/users/') ||
          state.matchedLocation.startsWith('/chat') ||
          state.matchedLocation.startsWith('/community') ||
          state.matchedLocation.startsWith('/itinerary') ||
          state.matchedLocation == '/settings/account' ||
          state.matchedLocation == '/matching/search' ||
          state.matchedLocation == '/report';
      final bool tryingToAccessAuth =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!loggedIn && tryingToAccessProtected) {
        return '/login';
      }
      if (loggedIn && tryingToAccessAuth) {
        return '/';
      }

      return null;
    },
  );
}
