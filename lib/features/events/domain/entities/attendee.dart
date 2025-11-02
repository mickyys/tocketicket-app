import 'package:equatable/equatable.dart';

class Attendee extends Equatable {
  final String name;
  final String lastName;
  final String documentNumber;
  final String documentType;
  final String validationCode;

  const Attendee({
    required this.name,
    required this.lastName,
    required this.documentNumber,
    required this.documentType,
    required this.validationCode,
  });

  @override
  List<Object?> get props => [
        name,
        lastName,
        documentNumber,
        documentType,
        validationCode,
      ];
}
