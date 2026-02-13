import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';
import 'package:travel_mate_app/presentation/common/empty_state_widget.dart';

/// 채팅방 목록 화면. 채팅방 생성·진입.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isEmpty = false;
    });

    try {
      // TODO: Implement actual chat room fetching logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate network

      setState(() {
        _isLoading = false;
        _isEmpty = true; // Simulate no chat rooms
      });
    } catch (e) {
      setState(() {
        _errorMessage = '채팅 목록을 불러오지 못했습니다.';
        _isLoading = false;
        _isEmpty = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: '채팅'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEmpty
              ? EmptyStateWidget(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: '대화 중인 채팅이 없습니다',
                  subtitle: '동행을 찾아 대화를 시작해 보세요!',
                  actionLabel: '동행 찾기',
                  onAction: () => context.go('/matching/search'),
                )
              : _errorMessage != null
                  ? EmptyStateWidget(
                      icon: Icons.cloud_off_rounded,
                      title: _errorMessage!,
                      isError: true,
                      onRetry: _loadChatRooms,
                    )
                  : ListView.builder(
                  itemCount: 5, // Simulate 5 chat rooms
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingSmall, vertical: AppConstants.paddingExtraSmall),
                      elevation: 0.5,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://picsum.photos/200/300?random=${index + 1}'),
                        ),
                        title: Text('사용자 ${index + 1}'),
                        subtitle: Text('마지막 메시지'),
                        trailing: Text('${index + 1}분 전'),
                        onTap: () {
                          context.go('/chat/room/chatRoomId${index + 1}'); // Navigate to chat room
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
