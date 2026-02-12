import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/domain/entities/post.dart';
import 'package:travel_mate_app/domain/usecases/get_post.dart';
import 'package:travel_mate_app/domain/usecases/delete_post.dart';
import 'package:travel_mate_app/presentation/common/report_button_widget.dart';

/// 게시글 상세 화면. 수정/삭제/신고 버튼.
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  Post? _post; // Will store post details

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
  }

  Future<void> _loadPostDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getPost = Provider.of<GetPost>(context, listen: false);
      final fetchedPost = await getPost.execute(widget.postId);

      setState(() {
        _post = fetchedPost;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load post: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePost() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final deletePost = Provider.of<DeletePost>(context, listen: false);
        await deletePost.execute(widget.postId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully!')),
          );
          context.go('/community'); // Go back to community list
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to delete post: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final isAuthor = _post?.authorId == currentUserUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          if (isAuthor) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.go('/community/post/${widget.postId}/edit'); // Navigate to edit post screen
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePost,
            ),
          ],
          if (!isAuthor && _post != null) // Allow reporting only if not author
            ReportButtonWidget(entityType: ReportEntityType.post, entityId: widget.postId),
        ],
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
              : _post == null
                  ? Center(
                      child: Text(
                        'Post not found.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _post!.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Text(
                            'Category: ${_post!.category} - Posted by ${_post!.authorId}', // TODO: Display author's nickname
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          if (_post!.imageUrls.isNotEmpty)
                            SizedBox(
                              height: 200, // Adjust height as needed
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _post!.imageUrls.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                      child: CachedNetworkImage(
                                        imageUrl: _post!.imageUrls[index],
                                        width: 250, // Adjust width as needed
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Text(
                            _post!.content,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),
                          Text(
                            'Comments (Placeholder)',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Text('No comments yet.', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
    );
  }
}
