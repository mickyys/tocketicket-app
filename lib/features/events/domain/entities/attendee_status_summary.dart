import 'package:equatable/equatable.dart';

class AttendeeStatusSummary extends Equatable {
  final int confirmed;
  final int unconfirmed;
  final int total;
  final List<CategoryScanInfo>? byCategory;

  const AttendeeStatusSummary({
    required this.confirmed,
    required this.unconfirmed,
    required this.total,
    this.byCategory,
  });

  @override
  List<Object?> get props => [confirmed, unconfirmed, total, byCategory];
}

class CategoryScanInfo extends Equatable {
  final String categoryId;
  final String categoryName;
  final int confirmed;
  final int unconfirmed;
  final int total;

  const CategoryScanInfo({
    required this.categoryId,
    required this.categoryName,
    required this.confirmed,
    required this.unconfirmed,
    required this.total,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    confirmed,
    unconfirmed,
    total,
  ];
}
