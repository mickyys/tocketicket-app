import 'package:tocke/features/events/domain/entities/attendee_status_summary.dart';

class AttendeeStatusSummaryModel extends AttendeeStatusSummary {
  AttendeeStatusSummaryModel({
    required int confirmed,
    required int unconfirmed,
    required int total,
    List<CategoryScanInfoModel>? byCategory,
  }) : super(
         confirmed: confirmed,
         unconfirmed: unconfirmed,
         total: total,
         byCategory: byCategory,
       );

  factory AttendeeStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendeeStatusSummaryModel(
      confirmed: json['confirmed'] ?? 0,
      unconfirmed: json['unconfirmed'] ?? 0,
      total: json['total'] ?? 0,
      byCategory:
          json['byCategory'] != null
              ? (json['byCategory'] as List)
                  .map((i) => CategoryScanInfoModel.fromJson(i))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confirmed': confirmed,
      'unconfirmed': unconfirmed,
      'total': total,
      'byCategory':
          (byCategory as List<CategoryScanInfoModel>?)
              ?.map((i) => i.toJson())
              .toList(),
    };
  }
}

class CategoryScanInfoModel extends CategoryScanInfo {
  CategoryScanInfoModel({
    required String categoryId,
    required String categoryName,
    required int confirmed,
    required int unconfirmed,
    required int total,
  }) : super(
         categoryId: categoryId,
         categoryName: categoryName,
         confirmed: confirmed,
         unconfirmed: unconfirmed,
         total: total,
       );

  factory CategoryScanInfoModel.fromJson(Map<String, dynamic> json) {
    return CategoryScanInfoModel(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      confirmed: json['confirmed'] ?? 0,
      unconfirmed: json['unconfirmed'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'confirmed': confirmed,
      'unconfirmed': unconfirmed,
      'total': total,
    };
  }
}
