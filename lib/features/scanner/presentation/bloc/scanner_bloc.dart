import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/check_ticket_status.dart';
import '../../domain/usecases/validate_ticket_qr.dart';
import '../../data/repositories/scan_history_repository.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final CheckTicketStatus checkTicketStatus;
  final ValidateTicketQR validateTicketQR;
  final ScanHistoryRepository scanHistoryRepository;

  ScannerBloc({
    required this.checkTicketStatus,
    required this.validateTicketQR,
    required this.scanHistoryRepository,
  }) : super(ScannerInitial()) {
    on<ScanQRCode>(_onScanQRCode);
    on<CheckTicketStatusEvent>(_onCheckTicketStatus);
    on<ConfirmValidationEvent>(_onConfirmValidation);
    on<ClearResultEvent>(_onClearResult);
    on<ResetScannerEvent>(_onResetScanner);
    on<GetScanHistoryEvent>(_onGetScanHistory);
    on<ClearScanHistoryEvent>(_onClearScanHistory);
  }

  Future<void> _onScanQRCode(
    ScanQRCode event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      AppLogger.info('Código QR escaneado: ${event.qrCode}');

      // Extraer el código de validación del QR
      final validationCode = _extractValidationCode(event.qrCode);

      if (validationCode.isEmpty) {
        emit(const ScannerError('Código QR inválido'));
        return;
      }

      // Consultar automáticamente el estado del ticket
      add(CheckTicketStatusEvent(validationCode));
    } catch (e) {
      AppLogger.error('Error procesando QR: $e');
      emit(ScannerError('Error procesando código QR: $e'));
    }
  }

  Future<void> _onCheckTicketStatus(
    CheckTicketStatusEvent event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      AppLogger.info('Consultando estado del ticket: ${event.validationCode}');
      emit(CheckingTicketStatus(event.validationCode));

      final result = await checkTicketStatus(event.validationCode);

      result.fold(
        (failure) {
          AppLogger.error('Error consultando estado: ${failure.toString()}');
          // Si el error es "Ticket no encontrado", emitir estado específico
          if (failure.toString().contains('Ticket no encontrado') ||
              failure.toString().contains('no encontrado')) {
            emit(TicketNotFound(event.validationCode));
          } else {
            emit(
              ScannerError('Error consultando ticket: ${failure.toString()}'),
            );
          }
        },
        (validationResult) async {
          AppLogger.info(
            'Estado del ticket consultado: ${validationResult.ticketStatus}',
          );

          // Guardar en el historial
          try {
            await scanHistoryRepository.saveScanResult(
              validationResult,
              'Scanner App', // Aquí podrías usar el nombre del usuario logueado
            );
          } catch (e) {
            AppLogger.error('Error guardando en historial: $e');
          }

          emit(TicketStatusLoaded(validationResult));
        },
      );
    } catch (e) {
      AppLogger.error('Error en consulta: $e');
      emit(ScannerError('Error inesperado: $e'));
    }
  }

  Future<void> _onConfirmValidation(
    ConfirmValidationEvent event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      AppLogger.info(
        'Confirmando validación del ticket: ${event.validationCode}',
      );
      emit(ValidatingTicket(event.validationCode));

      final result = await validateTicketQR(event.validationCode);

      result.fold(
        (failure) {
          AppLogger.error('Error validando ticket: ${failure.toString()}');
          // Si el error es "Ticket no encontrado", emitir estado específico
          if (failure.toString().contains('Ticket no encontrado') ||
              failure.toString().contains('no encontrado')) {
            emit(TicketNotFound(event.validationCode));
          } else {
            emit(ScannerError('Error validando ticket: ${failure.toString()}'));
          }
        },
        (validationResult) async {
          AppLogger.info(
            'Ticket validado exitosamente: ${validationResult.ticketStatus}',
          );

          // Actualizar en el historial con el estado validado
          try {
            await scanHistoryRepository.saveScanResult(
              validationResult,
              'Scanner App', // Aquí podrías usar el nombre del usuario logueado
            );
          } catch (e) {
            AppLogger.error('Error actualizando historial: $e');
          }

          emit(ValidationSuccess(validationResult));
        },
      );
    } catch (e) {
      AppLogger.error('Error en validación: $e');
      emit(ScannerError('Error inesperado: $e'));
    }
  }

  Future<void> _onClearResult(
    ClearResultEvent event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerReady());
  }

  Future<void> _onResetScanner(
    ResetScannerEvent event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerInitial());
  }

  Future<void> _onGetScanHistory(
    GetScanHistoryEvent event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      AppLogger.info('Obteniendo historial de escaneos');
      final history = await scanHistoryRepository.getScanHistory();
      emit(ScanHistoryLoaded(history));
    } catch (e) {
      AppLogger.error('Error obteniendo historial: $e');
      emit(ScannerError('Error obteniendo historial: $e'));
    }
  }

  Future<void> _onClearScanHistory(
    ClearScanHistoryEvent event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      AppLogger.info('Limpiando historial de escaneos');
      await scanHistoryRepository.clearHistory();
      emit(ScanHistoryCleared());
      // Recargar el historial vacío
      add(GetScanHistoryEvent());
    } catch (e) {
      AppLogger.error('Error limpiando historial: $e');
      emit(ScannerError('Error limpiando historial: $e'));
    }
  }

  /// Extrae el código de validación del QR escaneado
  String _extractValidationCode(String qrCode) {
    try {
      // Si el QR es una URL, extraer el código de validación
      if (qrCode.contains('validation') || qrCode.contains('ticket')) {
        final uri = Uri.tryParse(qrCode);
        if (uri != null) {
          // Buscar el código en los parámetros de query
          final code =
              uri.queryParameters['code'] ??
              uri.queryParameters['validationCode'] ??
              uri.pathSegments.last;
          return code;
        }
      }

      // Si es solo un código, devolverlo directamente
      return qrCode.trim();
    } catch (e) {
      AppLogger.error('Error extrayendo código de validación: $e');
      return '';
    }
  }
}
