import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/validation_result.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_state.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Escaneos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearHistoryDialog(context),
            tooltip: 'Limpiar historial',
          ),
        ],
      ),
      body: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          return _buildHistoryList();
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    // TODO: Implementar almacenamiento local del historial
    // Por ahora mostramos datos de ejemplo
    final List<ValidationResult> historyItems = [
      const ValidationResult(
        isValid: true,
        message: 'Ticket válido',
        validationCode: 'TKT-001-ABC123',
        status: ValidationStatus.valid,
        eventName: 'Concierto Rock 2025',
        ticketName: 'VIP',
        participantName: 'Juan Pérez',
        participantEmail: 'juan@email.com',
        validatedAt: null,
      ),
      const ValidationResult(
        isValid: false,
        message: 'Ticket ya utilizado',
        validationCode: 'TKT-002-DEF456',
        status: ValidationStatus.used,
        eventName: 'Festival de Jazz',
        ticketName: 'General',
        participantName: 'María González',
        participantEmail: 'maria@email.com',
        validatedAt: null,
      ),
    ];

    if (historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No hay escaneos recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los códigos QR escaneados aparecerán aquí',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.padding),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return _buildHistoryCard(item);
      },
    );
  }

  Widget _buildHistoryCard(ValidationResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.margin),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: () => _showDetailDialog(result),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(result.status),
                    color: _getStatusColor(result.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.validationCode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        result.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          result.status,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      result.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(result.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (result.eventName != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.event,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        result.eventName!,
                        style: const TextStyle(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (result.participantName != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        result.participantName!,
                        style: const TextStyle(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hace 5 minutos', // TODO: Calcular tiempo real
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(ValidationResult result) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getStatusIcon(result.status),
              color: _getStatusColor(result.status),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Detalles del Ticket')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Código', result.validationCode),
              _buildDetailRow('Estado', result.status.displayName),
              _buildDetailRow('Mensaje', result.message),
              if (result.eventName != null)
                _buildDetailRow('Evento', result.eventName!),
              if (result.ticketName != null)
                _buildDetailRow('Tipo de Ticket', result.ticketName!),
              if (result.participantName != null)
                _buildDetailRow('Participante', result.participantName!),
              if (result.participantEmail != null)
                _buildDetailRow('Email', result.participantEmail!),
              if (result.validatedAt != null)
                _buildDetailRow(
                  'Validado el',
                  _formatDate(result.validatedAt!),
                ),
              if (result.validatedBy != null)
                _buildDetailRow('Validado por', result.validatedBy!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          if (result.status == ValidationStatus.valid)
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // TODO: Permitir validar desde el historial
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Funcionalidad de validación desde historial pendiente',
                    ),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Validar'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Historial'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todo el historial de escaneos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar limpieza del historial
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historial limpiado'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.valid:
        return Icons.check_circle;
      case ValidationStatus.invalid:
        return Icons.cancel;
      case ValidationStatus.used:
        return Icons.check_circle_outline;
      case ValidationStatus.expired:
        return Icons.access_time;
      case ValidationStatus.notFound:
        return Icons.search_off;
    }
  }

  Color _getStatusColor(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.valid:
        return AppColors.success;
      case ValidationStatus.invalid:
        return AppColors.error;
      case ValidationStatus.used:
        return AppColors.warning;
      case ValidationStatus.expired:
        return AppColors.error;
      case ValidationStatus.notFound:
        return AppColors.grey;
    }
  }
}
