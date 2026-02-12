/// 태그 DTO( id, tagName, type ). 동행 검색 필터 등에 사용.
import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final int id;
  final String tagName;
  final String tagType; // e.g., 'travel_style', 'interest_activity'

  const Tag({
    required this.id,
    required this.tagName,
    required this.tagType,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      tagName: json['tag_name'] as String,
      tagType: json['tag_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_name': tagName,
      'tag_type': tagType,
    };
  }

  @override
  List<Object?> get props => [id, tagName, tagType];
}