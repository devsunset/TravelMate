import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/domain/entities/chat_room_info.dart';
import 'package:travel_mate_app/domain/usecases/get_chat_rooms.dart';
import 'package:travel_mate_app/domain/usecases/get_user_profile.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';
import 'package:travel_mate_app/presentation/common/empty_state_widget.dart';

/// 채팅방 목록 화면. Firestore 실시간 스트림으로 등록된 채팅방만 표시.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  String _timeAgo(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 전';
    return '방금';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      return Scaffold(
        appBar: const AppAppBar(title: '채팅'),
        body: const Center(child: Text('로그인이 필요합니다.')),
      );
    }

    final getChatRooms = Provider.of<GetChatRooms>(context);
    final getProfile = Provider.of<GetUserProfile>(context);

    return Scaffold(
      appBar: const AppAppBar(title: '채팅'),
      body: StreamBuilder<List<ChatRoomInfo>>(
        stream: getChatRooms.execute(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.cloud_off_rounded,
              title: '채팅 목록을 불러오지 못했습니다.',
              isError: true,
              onRetry: () {},
            );
          }
          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: '대화 중인 채팅이 없습니다',
              subtitle: '동행을 찾아 대화를 시작해 보세요!',
              actionLabel: '동행 찾기',
              onAction: () => context.go('/matching/search'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _ChatRoomTile(
                room: room,
                timeAgo: _timeAgo(room.lastMessageAt),
                getProfile: getProfile,
                onTap: (receiverNickname) {
                  context.push(
                    '/chat/room/${room.chatRoomId}',
                    extra: receiverNickname ?? room.otherParticipantId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomInfo room;
  final String timeAgo;
  final GetUserProfile getProfile;
  final void Function(String? receiverNickname) onTap;

  const _ChatRoomTile({
    required this.room,
    required this.timeAgo,
    required this.getProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProfile.execute(room.otherParticipantId),
      builder: (context, profileSnapshot) {
        final nickname = profileSnapshot.hasData
            ? (profileSnapshot.data?.nickname ?? '대화 상대')
            : '로딩...';
        final imageUrl = profileSnapshot.hasData?.profileImageUrl;

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
            vertical: AppConstants.paddingExtraSmall,
          ),
          elevation: 0.5,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                  ? NetworkImage(imageUrl)
                  : null,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            title: Text(nickname),
            subtitle: Text(
              room.lastMessage.isEmpty ? '(사진/첨부)' : room.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            onTap: () => onTap(profileSnapshot.hasData ? (profileSnapshot.data?.nickname ?? room.otherParticipantId) : room.otherParticipantId),
          ),
        );
      },
    );
  }
}
