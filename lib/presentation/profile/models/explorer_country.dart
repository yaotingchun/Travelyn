import 'package:flutter/material.dart';

/// Status of a country in the user's travel passport.
enum CountryStatus {
  explored,
  wishlist,
  someday,
}

/// Model representing a country with exploration details and map coordinates.
class ExplorerCountry {
  final String code; // ISO 2-letter or custom code e.g. 'MY', 'JP'
  final String name;
  final String flag;
  final CountryStatus status;
  final int visitCount;
  final int placesVisited;
  final String? lastVisitedDate;
  final String? note;
  /// Normalized map coordinate (x: 0.0..1.0, y: 0.0..1.0) on the vintage world projection
  final Offset mapCoordinate;

  const ExplorerCountry({
    required this.code,
    required this.name,
    required this.flag,
    required this.status,
    this.visitCount = 0,
    this.placesVisited = 0,
    this.lastVisitedDate,
    this.note,
    required this.mapCoordinate,
  });

  bool get isExplored => status == CountryStatus.explored;
  bool get isWishlist => status == CountryStatus.wishlist;
  bool get isSomeday => status == CountryStatus.someday;

  ExplorerCountry copyWith({
    String? code,
    String? name,
    String? flag,
    CountryStatus? status,
    int? visitCount,
    int? placesVisited,
    String? lastVisitedDate,
    String? note,
    Offset? mapCoordinate,
  }) {
    return ExplorerCountry(
      code: code ?? this.code,
      name: name ?? this.name,
      flag: flag ?? this.flag,
      status: status ?? this.status,
      visitCount: visitCount ?? this.visitCount,
      placesVisited: placesVisited ?? this.placesVisited,
      lastVisitedDate: lastVisitedDate ?? this.lastVisitedDate,
      note: note ?? this.note,
      mapCoordinate: mapCoordinate ?? this.mapCoordinate,
    );
  }
}
