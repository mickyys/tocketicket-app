import 'package:equatable/equatable.dart';

class ValidationResult extends Equatable {
  final bool isValid;
  final String message;
  final String validationCode;
  final ValidationStatus status;
  final String? eventName;
  final String? ticketName;
  final String? participantName;
  final String? participantEmail;
  final DateTime? validatedAt;
  final String? validatedBy;

  const ValidationResult({
    required this.isValid,
    required this.message,
    required this.validationCode,
    required this.status,
    this.eventName,
    this.ticketName,
    this.participantName,
    this.participantEmail,
    this.validatedAt,
    this.validatedBy,
  });

  @override
  List<Object?> get props => [
    isValid,
    message,
    validationCode,
    status,
    eventName,
    ticketName,
    participantName,
    participantEmail,
    validatedAt,
    validatedBy,
  ];
}

enum ValidationStatus { valid, invalid, used, expired, notFound }

extension ValidationStatusExtension on ValidationStatus {
  String get displayName {
    switch (this) {
      case ValidationStatus.valid:
        return 'Válido';
      case ValidationStatus.invalid:
        return 'Inválido';
      case ValidationStatus.used:
        return 'Ya utilizado';
      case ValidationStatus.expired:
        return 'Expirado';
      case ValidationStatus.notFound:
        return 'No encontrado';
    }
  }

  String get statusCode {
    switch (this) {
      case ValidationStatus.valid:
        return 'valid';
      case ValidationStatus.invalid:
        return 'invalid';
      case ValidationStatus.used:
        return 'used';
      case ValidationStatus.expired:
        return 'expired';
      case ValidationStatus.notFound:
        return 'not_found';
    }
  }

  static ValidationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return ValidationStatus.valid;
      case 'invalid':
        return ValidationStatus.invalid;
      case 'used':
        return ValidationStatus.used;
      case 'expired':
        return ValidationStatus.expired;
      case 'not_found':
        return ValidationStatus.notFound;
      default:
        return ValidationStatus.invalid;
    }
  }
}
