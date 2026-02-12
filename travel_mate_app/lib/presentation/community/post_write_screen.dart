import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File
import 'package:firebase_auth/firebase_auth.dart'; // Import for current user
import 'package:flutter_image_compress/flutter_image_compress.dart'; // For image compression

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/domain/entities/post.dart';
import 'package:travel_mate_app/domain/usecases/create_post.dart';
import 'package:travel_mate_app/domain/usecases/update_post.dart';
import 'package:travel_mate_app/domain/usecases/upload_post_image.dart';
import 'package:travel_mate_app/domain/usecases/get_post.dart';
import 'package:travel_mate_app/data/models/post_model.dart'; // Import PostModel for instantiation

class PostWriteScreen extends StatefulWidget {
  final String? postId; // Null for new post, provided for editing existing post

  const PostWriteScreen({Key? key, this.postId}) : super(key: key);

  @override
  State<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends State<PostWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? _selectedCategory;
  List<File> _pickedImages = [];
  List<String> _existingImageUrls = []; // For editing existing post

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = ['General', 'Tips', 'Stories', 'Questions', 'Meetups'];

  @override
  void initState() {
    super.initState();
    if (widget.postId != null) {
      _loadPostForEditing();
    }
  }

  Future<void> _loadPostForEditing() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final getPost = Provider.of<GetPost>(context, listen: false);
      final fetchedPost = await getPost.execute(widget.postId!);

      _titleController.text = fetchedPost.title;
      _contentController.text = fetchedPost.content;
      _selectedCategory = fetchedPost.category;
      _existingImageUrls = List.from(fetchedPost.imageUrls);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load post for editing: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      // Compress images before adding to _pickedImages
      List<File> compressedFiles = [];
      for (XFile image in pickedFiles) {
        final filePath = image.path;
        final targetPath = '${filePath}_compressed.jpg';
        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          filePath,
          targetPath,
          quality: 80,
          minWidth: 1024,
          minHeight: 1024,
          format: CompressFormat.jpeg,
        );
        if (compressedImage != null) {
          compressedFiles.add(File(compressedImage.path));
        }
      }

      setState(() {
        _pickedImages.addAll(compressedFiles);
      });
    }
  }

  void _removePickedImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  void _removeExistingImage(String url) {
    setState(() {
      _existingImageUrls.remove(url);
    });
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('User not logged in.');
        }

        // 1. Upload new images to Firebase Storage
        List<String> uploadedImageUrls = [];
        final uploadPostImage = Provider.of<UploadPostImage>(context, listen: false);
        for (File image in _pickedImages) {
          final imageUrl = await uploadPostImage.execute(widget.postId ?? currentUser.uid, image.path); // Use postId or current user UID for path
          uploadedImageUrls.add(imageUrl);
        }

        // Combine existing and new image URLs
        List<String> allImageUrls = [..._existingImageUrls, ...uploadedImageUrls];

        // 2. Create or Update Post entity
        final PostModel post = PostModel(
          id: widget.postId ?? '', // If new, backend will assign ID
          authorId: currentUser.uid,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory!,
          imageUrls: allImageUrls,
          createdAt: _post?.createdAt ?? DateTime.now(), // Preserve createdAt for existing post
          updatedAt: DateTime.now(),
        );

        // 3. Call CreatePost or UpdatePost usecase
        if (widget.postId == null) {
          final createPost = Provider.of<CreatePost>(context, listen: false);
          await createPost.execute(post);
        } else {
          final updatePost = Provider.of<UpdatePost>(context, listen: false);
          await updatePost.execute(post);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.postId == null ? 'Post created successfully!' : 'Post updated successfully!')),
          );
          context.pop(); // Go back to community screen
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to submit post: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postId == null ? 'Create New Post' : 'Edit Post'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        prefixIcon: Icon(Icons.text_fields),
                      ),
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      'Images',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    // Display existing images for editing
                    if (_existingImageUrls.isNotEmpty)
                      Wrap(
                        spacing: AppConstants.spacingSmall,
                        runSpacing: AppConstants.spacingSmall,
                        children: _existingImageUrls.map((url) {
                          return Stack(
                            children: [
                              Image.network(
                                url,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => _removeExistingImage(url),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    // Display newly picked images
                    Wrap(
                      spacing: AppConstants.spacingSmall,
                      runSpacing: AppConstants.spacingSmall,
                      children: _pickedImages.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final File image = entry.value;
                        return Stack(
                          children: [
                            Image.file(
                              image,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removePickedImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Images'),
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
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
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitPost,
                              child: Text(
                                widget.postId == null ? 'Create Post' : 'Update Post',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
