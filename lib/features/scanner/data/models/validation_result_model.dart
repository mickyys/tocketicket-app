import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'validation_result_model.g.dart';

@JsonSerializable()
class ValidationResultModel extends Equatable {
  final String eventName;
  final String participantName;
  final String participantRut;
  @JsonKey(name: 'ticketStatus')
  final String ticketStatus;
  final String categoryName;

  const ValidationResultModel({
    required this.eventName,
    required this.participantName,
    required this.participantRut,
    required this.ticketStatus,
    required this.categoryName,
  });

  factory ValidationResultModel.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationResultModelToJson(this);

  ValidationResultModel copyWith({
    String? eventName,
    String? participantName,
    String? participantRut,
    String? ticketStatus,
    String? categoryName,
  }) {
    return ValidationResultModel(
      eventName: eventName ?? this.eventName,
      participantName: participantName ?? this.participantName,
      participantRut: participantRut ?? this.participantRut,
      ticketStatus: ticketStatus ?? this.ticketStatus,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  List<Object?> get props => [
    eventName,
    participantName,
    participantRut,
    ticketStatus,
    categoryName,
  ];
}
