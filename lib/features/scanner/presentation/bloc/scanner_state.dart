import 'package:equatable/equatable.dart';
import '../../domain/entities/validation_result.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del scanner
class ScannerInitial extends ScannerState {}

/// Estado de scanning activo
class ScannerReady extends ScannerState {}

/// Estado consultando el estado del ticket
class CheckingTicketStatus extends ScannerState {
  final String validationCode;

  const CheckingTicketStatus(this.validationCode);

  @override
  List<Object> get props => [validationCode];
}

/// Estado con resultado de consulta
class TicketStatusLoaded extends ScannerState {
  final ValidationResult result;

  const TicketStatusLoaded(this.result);

  @override
  List<Object> get props => [result];
}

/// Estado validando ticket
class ValidatingTicket extends ScannerState {
  final String validationCode;

  const ValidatingTicket(this.validationCode);

  @override
  List<Object> get props => [validationCode];
}

/// Estado de validación exitosa
class ValidationSuccess extends ScannerState {
  final ValidationResult result;

  const ValidationSuccess(this.result);

  @override
  List<Object> get props => [result];
}

/// Estado de error
class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object> get props => [message];
}
