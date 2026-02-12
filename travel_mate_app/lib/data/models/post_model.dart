/// 게시글 DTO. JSON 직렬화 및 [Post] 엔티티 확장.
import 'package:travel_mate_app/domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.title,
    required super.content,
    required super.category,
    super.imageUrls,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'content': content,
      'category': category,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  PostModel copyWith({
    String? id,
    String? authorId,
    String? title,
    String? content,
    String? category,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
