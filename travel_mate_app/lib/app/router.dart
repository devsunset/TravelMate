/// GoRouter 설정. 로그인 여부에 따라 보호 경로 리다이렉트, 홈/로그인/프로필/채팅/커뮤니티/신고 등 경로 정의.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_mate_app/presentation/auth/login_screen.dart';
import 'package:travel_mate_app/presentation/auth/signup_screen.dart';
import 'package:travel_mate_app/presentation/profile/profile_detail_screen.dart';
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

/// 로그인 후 홈 화면(프로필/동행검색/채팅/커뮤니티/설정 진입, 로그아웃).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
              if (currentUserUid != null) {
                context.go('/users/$currentUserUid');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.go('/matching/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              context.go('/chat');
            },
          ),
          IconButton(
            icon: const Icon(Icons.public),
            onPressed: () {
              context.go('/community');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings/account');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to TripMate! You are logged in.'),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Logout'),
            ),
          ],
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
          return const SignUpScreen();
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
        path: '/report', // Route for submitting a report
        builder: (BuildContext context, GoRouterState state) {
          final args = state.extra as Map<String, dynamic>;
          return ReportSubmissionScreen(
            entityType: args['entityType'] as ReportEntityType,
            entityId: args['entityId'] as String,
            reporterUserId: args['reporterUserId'] as String,
          );
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
          state.matchedLocation == '/settings/account' ||
          state.matchedLocation == '/matching/search' ||
          state.matchedLocation == '/report'; // New protected route
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
