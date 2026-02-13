import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'package:travel_mate_app/core/io_stub/file_stub.dart';
import 'package:travel_mate_app/core/io_stub/picked_image_widget_io.dart' if (dart.library.html) 'package:travel_mate_app/core/io_stub/picked_image_widget_web.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for current user
import 'package:flutter_image_compress/flutter_image_compress.dart'; // For image compression

import 'package:travel_mate_app/app/theme.dart';
import 'package:travel_mate_app/app/constants.dart';
import 'package:travel_mate_app/presentation/common/app_app_bar.dart';
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
  Post? _loadedPost; // 수정 시 로드된 게시글 (createdAt 등 유지용)

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = ['General', 'Tips', 'Stories', 'Questions', 'Meetups'];
  static const Map<String, String> _categoryLabels = {
    'General': '일반', 'Tips': '팁', 'Stories': '이야기', 'Questions': '질문', 'Meetups': '밋업',
  };

  @override
  void initState() {
    super.initState();
    if (widget.postId != null && widget.postId!.isNotEmpty) {
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
      _selectedCategory = _categories.contains(fetchedPost.category) ? fetchedPost.category : null;
      _existingImageUrls = List.from(fetchedPost.imageUrls);
    } catch (e) {
      setState(() {
        _errorMessage = '글을 불러오지 못했습니다: ${e.toString()}';
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
          throw Exception('로그인이 필요합니다.');
        }

        // 1. 새 이미지를 백엔드에 업로드
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
          createdAt: _loadedPost?.createdAt ?? DateTime.now(), // Preserve createdAt for existing post
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
            SnackBar(content: Text(widget.postId == null ? '글이 등록되었습니다.' : '글이 수정되었습니다.')),
          );
          context.pop(); // Go back to community screen
        }
      } catch (e) {
        setState(() {
          _errorMessage = '글 등록/수정 실패: ${e.toString()}';
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
      appBar: AppAppBar(title: widget.postId == null ? '글쓰기' : '글 수정'),
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
                        labelText: '제목',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '제목을 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: '내용',
                        prefixIcon: Icon(Icons.text_fields),
                      ),
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '내용을 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMedium),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory != null && _categories.contains(_selectedCategory) ? _selectedCategory : null,
                      decoration: const InputDecoration(
                        labelText: '카테고리',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(_categoryLabels[category] ?? category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) => value == null ? '카테고리를 선택하세요' : null,
                    ),
                    const SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      '이미지',
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
                            widgetForPickedFile(image, width: 100, height: 100, fit: BoxFit.cover),
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
                      label: const Text('이미지 추가'),
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
                                widget.postId == null ? '글 등록' : '글 수정',
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
