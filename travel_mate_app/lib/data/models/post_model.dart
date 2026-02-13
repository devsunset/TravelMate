/// 게시글 DTO. JSON 직렬화 및 [Post] 엔티티 확장.
/// 백엔드(Sequelize)는 id, authorId 등을 int로 보낼 수 있으므로 int/String 모두 파싱.
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

  static String _toString(dynamic v) => v == null ? '' : (v is int ? v.toString() : v as String);
  static DateTime _toDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.parse(v.toString());
  }
  static List<String> _toStringList(List<dynamic>? list) =>
      list?.map((e) => e == null ? '' : (e is int ? e.toString() : e as String)).toList() ?? const [];

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'] ?? (json['Category'] is Map ? (json['Category'] as Map)['name'] : null);
    return PostModel(
      id: _toString(json['id']),
      authorId: _toString(json['authorId']),
      title: _toString(json['title']),
      content: _toString(json['content']),
      category: _toString(categoryRaw),
      imageUrls: _toStringList(json['imageUrls'] as List<dynamic>?),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
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
