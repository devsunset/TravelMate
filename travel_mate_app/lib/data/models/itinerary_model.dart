/// 일정 DTO. JSON 직렬화 및 [Itinerary] 엔티티 확장.
import 'package:travel_mate_app/domain/entities/itinerary.dart';

class ItineraryModel extends Itinerary {
  const ItineraryModel({
    required super.id,
    required super.authorId,
    required super.title,
    required super.description,
    required super.startDate,
    required super.endDate,
    super.imageUrls,
    super.mapData,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mapData: (json['mapData'] as List<dynamic>?)
              ?.map((e) => Map<String, double>.from(e as Map))
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
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'imageUrls': imageUrls,
      'mapData': mapData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  ItineraryModel copyWith({
    String? id,
    String? authorId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? imageUrls,
    List<Map<String, double>>? mapData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItineraryModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrls: imageUrls ?? this.imageUrls,
      mapData: mapData ?? this.mapData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
