import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/check_ticket_status.dart';
import '../../domain/usecases/validate_ticket_qr.dart';
import '../../domain/usecases/update_ticket_runner_data.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final CheckTicketStatus checkTicketStatus;
  final ValidateTicketQR validateTicketQR;
  final UpdateTicketRunnerData updateTicketRunnerData;

  ScannerBloc({
    required this.checkTicketStatus,
    required this.validateTicketQR,
    required this.updateTicketRunnerData,
  }) : super(ScannerInitial()) {
    on<ScanQRCode>(_onScanQRCode);
    on<CheckTicketStatusEvent>(_onCheckTicketStatus);
    on<ConfirmValidationEvent>(_onConfirmValidation);
    on<UpdateRunnerDataEvent>(_onUpdateRunnerData);
    on<ClearResultEvent>(_onClearResult);
    on<ResetScannerEvent>(_onResetScanner);
  }

  String? _currentEventId;

  Future<void> _onScanQRCode(
    ScanQRCode event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      AppLogger.info('Código QR escaneado: ${event.qrCode}');
      _currentEventId = event.eventId;

      final validationCode = _extractValidationCode(event.qrCode);

      if (validationCode.isEmpty) {
        emit(const ScannerError('Código QR inválido'));
        return;
      }

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
          if (failure.toString().contains('Ticket no encontrado') ||
              failure.toString().contains('no encontrado')) {
            emit(TicketNotFound(event.validationCode));
          } else {
            emit(
              ScannerError('Error consultando ticket: ${failure.toString()}'),
            );
          }
        },
        (validationResult) {
          AppLogger.info(
            'Estado del ticket consultado: ${validationResult.ticketStatus}',
          );
          if (_currentEventId != null &&
              validationResult.eventName.isNotEmpty) {
            AppLogger.info(
              'Ticket para evento: ${validationResult.eventName} (Validando contra eventId: $_currentEventId)',
            );
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
          if (failure.toString().contains('Ticket no encontrado') ||
              failure.toString().contains('no encontrado')) {
            emit(TicketNotFound(event.validationCode));
          } else {
            emit(ScannerError('Error validando ticket: ${failure.toString()}'));
          }
        },
        (validationResult) {
          AppLogger.info(
            'Ticket validado exitosamente: ${validationResult.ticketStatus}',
          );
          emit(ValidationSuccess(validationResult));
        },
      );
    } catch (e) {
      AppLogger.error('Error en validación: $e');
      emit(ScannerError('Error inesperado: $e'));
    }
  }

  Future<void> _onUpdateRunnerData(
    UpdateRunnerDataEvent event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      AppLogger.info(
        'Actualizando datos del corredor: ${event.validationCode}, número: ${event.runnerNumber}, chip: ${event.chipId}',
      );
      emit(SavingRunnerData(event.validationCode));

      final result = await updateTicketRunnerData(
        UpdateTicketRunnerDataParams(
          validationCode: event.validationCode,
          runnerNumber: event.runnerNumber,
          chipId: event.chipId,
        ),
      );

      result.fold(
        (failure) {
          AppLogger.error(
            'Error actualizando datos del corredor: ${failure.toString()}',
          );
          emit(ScannerError('Error guardando datos: ${failure.toString()}'));
        },
        (validationResult) {
          AppLogger.info('Datos del corredor actualizados exitosamente');
          emit(RunnerDataSaved(validationResult));
        },
      );
    } catch (e) {
      AppLogger.error('Error en actualización: $e');
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
