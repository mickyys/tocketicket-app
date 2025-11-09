import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object> get props => [];
}

/// Evento para escanear un código QR
class ScanQRCode extends ScannerEvent {
  final String qrCode;

  const ScanQRCode(this.qrCode);

  @override
  List<Object> get props => [qrCode];
}

/// Evento para consultar el estado de un ticket
class CheckTicketStatusEvent extends ScannerEvent {
  final String validationCode;

  const CheckTicketStatusEvent(this.validationCode);

  @override
  List<Object> get props => [validationCode];
}

/// Evento para confirmar validación de un ticket
class ConfirmValidationEvent extends ScannerEvent {
  final String validationCode;

  const ConfirmValidationEvent(this.validationCode);

  @override
  List<Object> get props => [validationCode];
}

/// Evento para limpiar el resultado
class ClearResultEvent extends ScannerEvent {}

/// Evento para reiniciar el scanner
class ResetScannerEvent extends ScannerEvent {}

/// Evento para obtener el historial de escaneos
class GetScanHistoryEvent extends ScannerEvent {}

/// Evento para limpiar el historial
class ClearScanHistoryEvent extends ScannerEvent {}
