import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/domain/entities/post.dart';
import 'package:travel_mate_app/domain/usecases/get_posts.dart';

/// 커뮤니티 게시글 목록 화면. 글쓰기·상세 이동.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getPosts = Provider.of<GetPosts>(context, listen: false);
      final fetchedPosts = await getPosts.execute();

      setState(() {
        _posts = fetchedPosts;
        _isLoading = false;
        if (_posts.isEmpty) {
          _errorMessage = 'No posts yet. Be the first to share your travel story!';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load posts: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Board'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/community/post/new'); // Navigate to create new post screen
            },
          ),
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
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: AppConstants.paddingSmall),
                        elevation: 1,
                        child: ListTile(
                          leading: post.imageUrls.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(post.imageUrls.first),
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.image_not_supported),
                                ),
                          title: Text(post.title),
                          subtitle: Text('Category: ${post.category} - Posted by ${post.authorId}'), // TODO: Display author's nickname
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context.go('/community/post/${post.id}'); // Navigate to post detail
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
