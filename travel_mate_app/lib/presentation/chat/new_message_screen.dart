import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/domain/usecases/send_private_message.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';

/// 1:1 쪽지 작성·발송 화면.
class NewMessageScreen extends StatefulWidget {
  final String receiverUserId;
  final String? receiverNickname;

  const NewMessageScreen({
    Key? key,
    required this.receiverUserId,
    this.receiverNickname,
  }) : super(key: key);

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sendPrivateMessage = Provider.of<SendPrivateMessage>(context, listen: false);
      await sendPrivateMessage.execute(
        receiverId: widget.receiverUserId,
        content: _messageController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully!')),
        );
        _messageController.clear();
        context.pop(); // Go back after sending message
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send message: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: widget.receiverNickname != null ? '${widget.receiverNickname}에게 쪽지' : '새 쪽지',
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'This is where the chat history would be displayed.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey.withOpacity(0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: AppConstants.paddingSmall),
                    ),
                    maxLines: null, // Allows multiline input
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                _isLoading
                    ? const CircularProgressIndicator()
                    : FloatingActionButton(
                        onPressed: _sendMessage,
                        mini: true,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.send, color: AppColors.onPrimary),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
