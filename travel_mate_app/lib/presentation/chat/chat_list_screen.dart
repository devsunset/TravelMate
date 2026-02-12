import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';

/// 채팅방 목록 화면. 채팅방 생성·진입.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  // List<ChatRoom> _chatRooms = []; // Will store chat rooms

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual chat room fetching logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate network

      setState(() {
        // _chatRooms = fetchedChatRooms;
        _isLoading = false;
        // Simulate no chat rooms
        _errorMessage = 'No active chats. Start a conversation with a new mate!';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load chat rooms: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                        title: Text('Chat with User ${index + 1}'),
                        subtitle: Text('Last message: Hello there!'),
                        trailing: Text('1${index} min ago'),
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
