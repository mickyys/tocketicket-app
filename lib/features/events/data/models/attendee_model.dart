import 'package:json_annotation/json_annotation.dart';

part 'attendee_model.g.dart';

@JsonSerializable()
class AttendeeModel {
  final String name;
  final String lastName;
  final String documentNumber;
  final String documentType;
  final String validationCode;

  AttendeeModel({
    required this.name,
    required this.lastName,
    required this.documentNumber,
    required this.documentType,
    required this.validationCode,
  });

  factory AttendeeModel.fromJson(Map<String, dynamic> json) =>
      _$AttendeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendeeModelToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastName': lastName,
      'documentNumber': documentNumber,
      'documentType': documentType,
      'validationCode': validationCode,
    };
  }
}
