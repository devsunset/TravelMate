/// 여행 일정 엔티티(제목, 설명, 기간, 이미지 URL, 지도 데이터).
import 'package:equatable/equatable.dart';

class Itinerary extends Equatable {
  final String id;
  final String authorId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> imageUrls;
  final List<Map<String, double>> mapData; // Example: List of {latitude, longitude} for markers/route
  final DateTime createdAt;
  final DateTime updatedAt;
  // TODO: Add fields for likes, comments count etc.
  // TODO: Add ItineraryDays and ItineraryActivities as nested objects/entities

  const Itinerary({
    required this.id,
    required this.authorId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.imageUrls = const [],
    this.mapData = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        authorId,
        title,
        description,
        startDate,
        endDate,
        imageUrls,
        mapData,
        createdAt,
        updatedAt,
      ];
}