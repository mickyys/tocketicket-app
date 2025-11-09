import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/validation_result.dart';
import '../../domain/usecases/check_ticket_status.dart';
import '../../domain/usecases/validate_ticket_qr.dart';
import '../../data/repositories/scan_history_repository.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScannerBloc(
        checkTicketStatus: context.read<CheckTicketStatus>(),
        validateTicketQR: context.read<ValidateTicketQR>(),
        scanHistoryRepository: ScanHistoryRepository(),
      ),
      child: const QRScannerView(),
    );
  }
}

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  DateTime? _lastScanTime;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentValidationCode; // Agregar variable para el código actual

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    try {
      _setupScanner();
      return;
    } catch (e) {
      // Error al solicitar permisos
      if (mounted) {
        _showPermissionErrorDialog();
      }
    }
  }

  void _setupScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _showPermissionErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de Permisos'),
        content: const Text(
          'Ocurrió un error al solicitar permisos de cámara. '
          'Por favor, reinicia la aplicación e intenta de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeScanner(); // Reintentar
            },
            child: const Text('Reintentar'),
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
        _currentValidationCode = code; // Guardar el código actual

        // Vibrar
        _vibrate();

        // Procesar el código
        context.read<ScannerBloc>().add(ScanQRCode(code));
      }
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

  String _getTicketStatusText(String ticketStatus) {
    switch (ticketStatus) {
      case 'valid':
        return 'Ticket válido, listo para usar';
      case 'validated':
        return 'Ticket ya validado y utilizado';
      case 'expired':
        return 'Ticket expirado';
      case 'invalid_replaced':
        return 'Ticket inválido - fue reemplazado';
      case 'invalid_cancelled':
        return 'Ticket inválido - fue cancelado';
      case 'invalid':
        return 'Ticket inválido';
      default:
        return 'Estado desconocido';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
            onPressed: () {
              _scannerController?.toggleTorch();
              setState(() {});
            },
          ),
        ],
      ),
      body: BlocListener<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is TicketStatusLoaded) {
            _showValidationDialog(context, state.result);
          } else if (state is ValidationSuccess) {
            _showSuccessDialog(context, state.result);
          } else if (state is TicketNotFound) {
            _showTicketNotFoundDialog(context, state.validationCode);
          } else if (state is ScannerError) {
            _showErrorDialog(context, state.message);
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: AppColors.greyLight),
            SizedBox(height: 16),
            Text(
              'Inicializando cámara...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return MobileScanner(controller: _scannerController!, onDetect: _onDetect);
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

  void _showValidationDialog(BuildContext context, ValidationResult result) {
    // Capturar la referencia al bloc antes de mostrar el diálogo
    final scannerBloc = context.read<ScannerBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Información del Ticket'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evento: ${result.eventName}'),
            const SizedBox(height: 8),
            Text('Participante: ${result.participantName}'),
            const SizedBox(height: 8),
            Text(
              '${result.documentType.toUpperCase()}: ${result.participantRut}',
            ),
            const SizedBox(height: 8),
            Text('Estado del Participante: ${result.participantStatus}'),
            const SizedBox(height: 8),
            Text('Correlativo del Ticket: ${result.ticketCorrelative}'),
            const SizedBox(height: 8),
            Text('Categoría: ${result.categoryName}'),
            const SizedBox(height: 8),
            if (result.ticketName != null) ...[
              Text('Ticket: ${result.ticketName}'),
              const SizedBox(height: 8),
            ],
            if (result.purchaseDate != null) ...[
              Text('Fecha de Compra: ${_formatDateTime(result.purchaseDate!)}'),
              const SizedBox(height: 8),
            ],
            if (result.validatedAt != null) ...[
              Text('Validado en: ${_formatDateTime(result.validatedAt!)}'),
              const SizedBox(height: 8),
            ],
            Text('Estado: ${_getTicketStatusText(result.ticketStatus)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetScanning();
            },
            child: const Text('Cerrar'),
          ),
          if (result.ticketStatus == 'valid')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Llamar al endpoint POST("/tickets/validate-qr")
                final validationCode =
                    result.validationCode ?? _currentValidationCode;
                if (validationCode != null) {
                  // Usar la referencia capturada del bloc
                  scannerBloc.add(ConfirmValidationEvent(validationCode));
                }
              },
              child: const Text('Validar'),
            ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, ValidationResult result) {
    _vibrate();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Validación Exitosa',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'El ticket ha sido validado correctamente.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                _buildInfoRow('Participante', result.participantName),
                const SizedBox(height: 12),
                _buildInfoRow('Evento', result.eventName),
                const SizedBox(height: 12),
                _buildInfoRow('Categoría', result.categoryName),
                const SizedBox(height: 12),
                _buildInfoRow('RUT', result.participantRut),
                if (result.ticketName != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow('Nombre del Ticket', result.ticketName!),
                ],
                if (result.purchaseDate != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Fecha de Compra',
                    _formatDateTime(result.purchaseDate!),
                  ),
                ],
                if (result.validatedAt != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Validado en',
                    _formatDateTime(result.validatedAt!),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetScanning();
                        },
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  void _showTicketNotFoundDialog(BuildContext context, String validationCode) {
    _vibrate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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

  void _showErrorDialog(BuildContext context, String message) {
    _vibrate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
}
