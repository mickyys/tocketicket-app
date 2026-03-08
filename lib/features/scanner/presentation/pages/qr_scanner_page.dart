import '../../../../features/events/presentation/bloc/participant_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/read_history_service.dart';
import '../../domain/entities/validation_result.dart';
import '../../domain/entities/read_record.dart';
import '../../domain/usecases/check_ticket_status.dart';
import '../../domain/usecases/validate_ticket_qr.dart';
import '../../domain/usecases/update_ticket_runner_data.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';
import '../widgets/ticket_status_card.dart';

class QRScannerPage extends StatelessWidget {
  final VoidCallback? onScanSaved;
  final String? eventId;
  final String? eventName;

  const QRScannerPage({
    super.key,
    this.onScanSaved,
    this.eventId,
    this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ScannerBloc(
            checkTicketStatus: context.read<CheckTicketStatus>(),
            validateTicketQR: context.read<ValidateTicketQR>(),
            updateTicketRunnerData: context.read<UpdateTicketRunnerData>(),
          ),
      child: QRScannerView(
        onScanSaved: onScanSaved,
        eventId: eventId,
        eventName: eventName,
      ),
    );
  }
}

class QRScannerView extends StatefulWidget {
  final VoidCallback? onScanSaved;
  final String? eventId;
  final String? eventName;

  const QRScannerView({
    super.key,
    this.onScanSaved,
    this.eventId,
    this.eventName,
  });

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  DateTime? _lastScanTime;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ScannerBloc _scannerBloc;
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScanner();
    });
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      // Configurar el audio player para iOS/macOS
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      _audioInitialized = true;
    } catch (e) {
      // Ignorar errores de inicialización de audio
      debugPrint('Error initializing audio: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scannerBloc = context.read<ScannerBloc>();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    try {
      debugPrint('QRScanner: Checking camera status...');
      final currentStatus = await Permission.camera.status;
      debugPrint('QRScanner: Current status is $currentStatus');

      if (currentStatus.isGranted) {
        _startScannerController();
        return;
      }

      debugPrint('QRScanner: Requesting camera permission...');
      final status = await Permission.camera.request();
      debugPrint('QRScanner: Request result: $status');

      if (status.isGranted) {
        _startScannerController();
      } else {
        if (mounted) {
          _showPermissionDialog();
        }
      }
    } catch (e) {
      debugPrint('QRScanner: Error initializing: $e');
    }
  }

  void _startScannerController() {
    if (!mounted) return;
    debugPrint('QRScanner: Starting controller...');
    setState(() {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: [BarcodeFormat.qrCode],
      );
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permiso de Cámara'),
            content: const Text(
              'Esta aplicación necesita acceso a la cámara para escanear códigos QR.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Configuración'),
              ),
            ],
          ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final now = DateTime.now();
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < AppConstants.scanCooldown) {
      return;
    }

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final code = barcode.rawValue;

      if (code != null && code.isNotEmpty) {
        _lastScanTime = now;
        _isScanning = false;

        // Reproducir sonido de scan
        _playSound(AppConstants.scanSuccessSound);

        // Vibrar
        _vibrate();

        // Procesar el código con el eventId si existe
        _scannerBloc.add(ScanQRCode(code, eventId: widget.eventId));
      }
    }
  }

  Future<void> _playSound(String soundPath) async {
    if (!_audioInitialized) return;
    try {
      // Detener cualquier reproducción anterior
      await _audioPlayer.stop();
      // Usar la ruta sin 'assets/' para AssetSource
      final source = AssetSource(soundPath.replaceFirst('assets/', ''));
      await _audioPlayer.play(source);
    } catch (e) {
      // Ignorar errores de audio - no son críticos para la funcionalidad
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _vibrate() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      // Ignorar errores de vibración
    }
  }

  void _resetScanning() {
    setState(() {
      _isScanning = true;
      _lastScanTime = null;
    });
  }

  void _showManualCodeDialog() {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ingresar Código Manualmente'),
            content: TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: 'Ingresa el código QR',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.qr_code),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final code = codeController.text.trim();
                  if (code.isNotEmpty) {
                    Navigator.of(context).pop();
                    _playSound(AppConstants.scanSuccessSound);
                    _vibrate();
                    _scannerBloc.add(ScanQRCode(code, eventId: widget.eventId));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Validar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar Ticket'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(
              _scannerController?.torchEnabled == true
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
            onPressed:
                _scannerController != null
                    ? () async {
                      try {
                        await _scannerController?.toggleTorch();
                        if (mounted) {
                          setState(() {});
                        }
                      } catch (e) {
                        debugPrint('Error toggling torch: $e');
                      }
                    }
                    : null,
          ),
        ],
      ),
      body: BlocListener<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is TicketStatusLoaded) {
            _showValidationResult(context, state.result);
          } else if (state is ValidationSuccess) {
            // Guardar en historial cuando se valida exitosamente (sin necesariamente guardar datos extra)
            _saveToReadHistory(state.result);
            _showValidationResult(context, state.result);
          } else if (state is TicketNotFound) {
            _showTicketNotFoundDialog(context, state.validationCode);
          } else if (state is ScannerError) {
            // Cerrar cualquier modal abierto antes de mostrar el error
            Navigator.of(context).popUntil((route) => route.isFirst);
            _showErrorDialog(context, state.message);
          } else if (state is RunnerDataSaved) {
            // Ya no cerramos la pantalla automáticamente
            // Guardar en historial antes de mostrar confirmación
            _saveToReadHistory(state.result);
            _showDataSavedSnackbar(context, state.result);
            // Notificar al padre que se guardó un registro
            widget.onScanSaved?.call();
            // No reseteamos el scanner aquí porque seguimos en el detalle
          } else if (state is ValidationSuccess) {
            // Guardar en historial cuando se valida exitosamente (sin necesariamente guardar datos extra)
            _saveToReadHistory(state.result);
            _showValidationResult(context, state.result);
          }
        },
        child: BlocBuilder<ScannerBloc, ScannerState>(
          builder: (context, state) {
            return Stack(
              children: [
                _buildScannerView(),
                _buildOverlay(),
                if (state is CheckingTicketStatus || state is ValidatingTicket)
                  _buildLoadingOverlay(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    if (_scannerController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: AppColors.greyLight),
            const SizedBox(height: 16),
            const Text(
              'Inicializando cámara...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _initializeScanner(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Solicitar Permisos'),
            ),
          ],
        ),
      );
    }

    return MobileScanner(
      controller: _scannerController!,
      onDetect: _onDetect,
      errorBuilder: (context, error) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error de cámara: ${error.errorCode}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              if (error.errorDetails?.message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error.errorDetails!.message!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _initializeScanner(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Esquinas del marco
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primary, width: 4),
                          left: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primary, width: 4),
                          right: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.primary,
                            width: 4,
                          ),
                          left: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.primary,
                            width: 4,
                          ),
                          right: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Escanea el código QR del ticket',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apunta la cámara hacia el código QR',
              style: TextStyle(color: AppColors.white, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showManualCodeDialog,
              icon: const Icon(Icons.keyboard),
              label: const Text('Ingresar Manualmente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(ScannerState state) {
    String message;
    if (state is CheckingTicketStatus) {
      message = 'Consultando estado del ticket...';
    } else if (state is ValidatingTicket) {
      message = 'Validando ticket...';
    } else {
      message = 'Procesando...';
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showValidationResult(BuildContext context, ValidationResult result) {
    _playSound(AppConstants.scanSuccessSound);
    _vibrate();

    // Validar si el ticket pertenece al evento actual (comparando nombres)
    final bool isDifferentEvent =
        widget.eventName != null &&
        result.eventName.isNotEmpty &&
        result.eventName.toLowerCase().trim() !=
            widget.eventName!.toLowerCase().trim();

    if (isDifferentEvent) {
      _showDifferentEventDialog(context, result);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BlocBuilder<ScannerBloc, ScannerState>(
              bloc: _scannerBloc,
              builder: (context, state) {
                final isSaving = state is SavingRunnerData;
                final currentResult =
                    (state is RunnerDataSaved) ? state.result : result;

                return TicketStatusCard(
                  ticket: currentResult,
                  runnerNumber: currentResult.runnerNumber ?? '',
                  chipId: currentResult.chipId ?? '',
                  isFirstTime: currentResult.ticketStatus == 'valid',
                  isSaving: isSaving,
                  onNewScan: () {
                    _saveToReadHistory(currentResult);
                    Navigator.of(context).pop();
                    _resetScanning();
                  },
                  onSaveData: (runnerNumber, chipId) {
                    final validationCode = currentResult.validationCode ?? '';
                    if (validationCode.isNotEmpty) {
                      _scannerBloc.add(
                        UpdateRunnerDataEvent(
                          validationCode: validationCode,
                          runnerNumber: runnerNumber,
                          chipId: chipId,
                        ),
                      );

                      // Si tenemos eventId, disparar actualización de participantes
                      if (widget.eventId != null) {
                        try {
                          context.read<ParticipantBloc>().add(
                            FetchParticipantsEvent(
                              eventId: widget.eventId!,
                              token: '',
                              pageSize: 1000,
                            ),
                          );
                        } catch (e) {
                          debugPrint(
                            'ParticipantBloc no encontrado en el contexto: $e',
                          );
                        }
                      }
                    }
                  },
                );
              },
            ),
      ),
    );
  }

  void _showDifferentEventDialog(
    BuildContext context,
    ValidationResult result,
  ) {
    _playSound(AppConstants.scanErrorSound);
    _vibrate();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.error),
                SizedBox(width: 8),
                Text('Evento Incorrecto'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Este ticket no pertenece a este evento.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Evento Ticket', result.eventName),
                _buildInfoRow(
                  'Evento Actual',
                  widget.eventName ?? 'Desconocido',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Por favor, verifique que está escaneando el código correcto para este evento.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetScanning();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketNotFoundDialog(BuildContext context, String validationCode) {
    _playSound(AppConstants.scanErrorSound);
    _vibrate();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.search_off, color: AppColors.warning),
                SizedBox(width: 8),
                Text('Ticket No Encontrado'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('El ticket escaneado no existe en el sistema.'),
                const SizedBox(height: 16),
                Text('Código: $validationCode'),
                const SizedBox(height: 16),
                const Text(
                  'Verifica que el código QR sea válido o contacta al organizador del evento.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetScanning();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
    );
  }

  void _saveToReadHistory(ValidationResult result) {
    // Función para capitalizar cada palabra
    String capitalizeName(String? name) {
      if (name == null || name.isEmpty) return '';
      return name
          .split(' ')
          .map(
            (word) =>
                word.isEmpty
                    ? ''
                    : word[0].toUpperCase() + word.substring(1).toLowerCase(),
          )
          .join(' ');
    }

    final record = ReadRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ticketId: result.validationCode ?? 'unknown',
      participantName: capitalizeName(result.participantName),
      eventName: result.eventName,
      timestamp: DateTime.now(),
      runnerNumber: result.runnerNumber ?? '0',
      chipId: result.chipId ?? '',
      isFirstTime: result.ticketStatus == 'valid', // Primera validación
    );

    ReadHistoryService.addRecord(record);
  }

  void _showErrorDialog(BuildContext context, String message) {
    _playSound(AppConstants.scanErrorSound);
    _vibrate();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: AppColors.error),
                SizedBox(width: 8),
                Text('Error'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetScanning();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
    );
  }

  void _showDataSavedSnackbar(BuildContext context, ValidationResult result) {
    _playSound(AppConstants.scanSuccessSound);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Datos guardados para ${result.participantName}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
