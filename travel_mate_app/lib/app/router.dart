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
import 'package:travel_mate_app/presentation/home/home_screen.dart';





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
          final raw = state.pathParameters['userId'] ?? '';
          final userId = raw.isNotEmpty ? Uri.decodeComponent(raw) : '';
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
          final raw = state.pathParameters['chatRoomId'] ?? '';
          final chatRoomId = raw.isNotEmpty ? Uri.decodeComponent(raw) : raw;
          final extra = state.extra;
          final receiverNickname = extra is String ? extra : null;
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
          final postId = state.pathParameters['postId'] ?? '';
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/community/post/:postId/edit',
        builder: (BuildContext context, GoRouterState state) {
          final postId = state.pathParameters['postId'] ?? '';
          return PostWriteScreen(postId: postId);
        },
      ),
      GoRoute(
        path: '/report',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra;
          if (extra is! Map<String, dynamic>) {
            return const _RedirectToHome();
          }
          final args = extra;
          final entityType = args['entityType'];
          final entityId = args['entityId'];
          final reporterUserId = args['reporterUserId'];
          if (entityType is! ReportEntityType || entityId is! String || reporterUserId is! String) {
            return const _RedirectToHome();
          }
          return ReportSubmissionScreen(
            entityType: entityType,
            entityId: entityId,
            reporterUserId: reporterUserId,
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
          final id = state.pathParameters['itineraryId'] ?? '';
          return ItineraryDetailScreen(itineraryId: id);
        },
      ),
      GoRoute(
        path: '/itinerary/:itineraryId/edit',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['itineraryId'] ?? '';
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

/// 신고 화면으로 잘못 진입했을 때(extra 없음) 홈으로 보냄.
class _RedirectToHome extends StatefulWidget {
  const _RedirectToHome();

  @override
  State<_RedirectToHome> createState() => _RedirectToHomeState();
}

class _RedirectToHomeState extends State<_RedirectToHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) GoRouter.of(context).go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
