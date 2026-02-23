import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user ID for comment authoring

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';

/// 댓글 부모 타입(게시글 또는 일정).
enum CommentParentType { post, itinerary }

/// 댓글 목록·작성 섹션 위젯.
class CommentSectionWidget extends StatefulWidget {
  final CommentParentType parentType;
  final String parentId;

  const CommentSectionWidget({
    Key? key,
    required this.parentType,
    required this.parentId,
  }) : super(key: key);

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  // List<Comment> _comments = []; // Will store comments

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual comment fetching logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate network

      setState(() {
        // _comments = fetchedComments;
        _isLoading = false;
        // Simulate no comments
        _errorMessage = '아직 댓글이 없습니다. 첫 댓글을 남겨 보세요!';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '댓글을 불러오지 못했습니다: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 입력하세요.')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 쓰려면 로그인하세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual add comment logic using AddComment usecase
      await Future.delayed(const Duration(seconds: 1)); // Simulate network

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 등록되었습니다.')),
        );
        _commentController.clear();
        _loadComments(); // Reload comments to show the new one
      }
    } catch (e) {
      setState(() {
        _errorMessage = '댓글 등록 실패: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '댓글',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3, // Simulate 3 comments
                itemBuilder: (context, index) {
                  return CommentItem(
                    author: 'Commenter ${index + 1}',
                    content: '샘플 댓글 ${index + 1}.',
                    time: '5 min ago',
                    isReply: index == 1, // Simulate a reply
                  );
                },
              ),
        const SizedBox(height: AppConstants.spacingLarge),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: '댓글을 입력하세요...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppConstants.paddingSmall),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
          ),
          maxLines: null,
        ),
      ],
    );
  }
}

class CommentItem extends StatelessWidget {
  final String author;
  final String content;
  final String time;
  final bool isReply;

  const CommentItem({
    Key? key,
    required this.author,
    required this.content,
    required this.time,
    this.isReply = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? AppConstants.paddingLarge : 0.0, bottom: AppConstants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.lightGrey,
            child: Icon(Icons.person, color: AppColors.grey),
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppConstants.spacingExtraSmall),
                GestureDetector(
                  onTap: () {
                    print('Reply to $author');
                    // TODO: Implement reply functionality (e.g., show reply input)
                  },
                  child: Text(
                    '답글',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
