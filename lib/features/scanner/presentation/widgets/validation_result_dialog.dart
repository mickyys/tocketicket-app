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
                    result.status.displayName,
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
          Text(result.message, style: const TextStyle(fontSize: 16)),
          if (result.participantName != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow('Participante', result.participantName!),
          ],
          if (result.participantEmail != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Email', result.participantEmail!),
          ],
          if (result.eventName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Evento', result.eventName!),
          ],
          if (result.ticketName != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Tipo de Ticket', result.ticketName!),
          ],
          if (result.validatedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Validado el', _formatDate(result.validatedAt!)),
          ],
          if (result.validatedBy != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Validado por', result.validatedBy!),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        if (result.status == ValidationStatus.valid)
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

  IconData _getStatusIcon() {
    switch (result.status) {
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

  Color _getStatusColor() {
    switch (result.status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
