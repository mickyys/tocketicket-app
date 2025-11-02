import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/validation_result.dart';

class ValidationResultDialog extends StatelessWidget {
  final ValidationResult result;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ValidationResultDialog({
    super.key,
    required this.result,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor()),
          const SizedBox(width: 8),
          Text('Estado del Ticket'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusDisplayName(result.ticketStatus),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Estado: ${_getStatusDisplayName(result.ticketStatus)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Participante', result.participantName),
          const SizedBox(height: 8),
          _buildInfoRow('RUT', result.participantRut),
          const SizedBox(height: 8),
          _buildInfoRow('Evento', result.eventName),
          const SizedBox(height: 8),
          _buildInfoRow('Categoría', result.categoryName),
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        if (result.ticketStatus == 'valid')
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Confirmar Validación'),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
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
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'valid':
        return 'Válido';
      case 'invalid':
        return 'Inválido';
      case 'used':
        return 'Usado';
      case 'expired':
        return 'Expirado';
      case 'notFound':
        return 'No encontrado';
      default:
        return 'Desconocido';
    }
  }

  IconData _getStatusIcon() {
    switch (result.ticketStatus) {
      case 'valid':
        return Icons.check_circle;
      case 'invalid':
        return Icons.cancel;
      case 'used':
        return Icons.check_circle_outline;
      case 'expired':
        return Icons.access_time;
      case 'notFound':
        return Icons.search_off;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor() {
    switch (result.ticketStatus) {
      case 'valid':
        return AppColors.success;
      case 'invalid':
        return AppColors.error;
      case 'used':
        return AppColors.warning;
      case 'expired':
        return AppColors.error;
      case 'notFound':
        return AppColors.grey;
      default:
        return AppColors.grey;
    }
  }
}
