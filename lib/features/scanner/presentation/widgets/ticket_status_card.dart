import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/validation_result.dart';

class TicketStatusCard extends StatefulWidget {
  final ValidationResult ticket;
  final String? runnerNumber;
  final String? chipId;
  final bool isFirstTime;
  final VoidCallback onNewScan;
  final Function(String, String) onSaveData;
  final bool isSaving;

  const TicketStatusCard({
    super.key,
    required this.ticket,
    this.runnerNumber,
    this.chipId,
    required this.isFirstTime,
    required this.onNewScan,
    required this.onSaveData,
    this.isSaving = false,
  });

  @override
  State<TicketStatusCard> createState() => _TicketStatusCardState();
}

class _TicketStatusCardState extends State<TicketStatusCard> {
  late TextEditingController _runnerNumberController;
  late TextEditingController _chipIdController;

  @override
  void initState() {
    super.initState();
    _runnerNumberController = TextEditingController(
      text: widget.runnerNumber ?? '',
    );
    _chipIdController = TextEditingController(text: widget.chipId ?? '');
  }

  @override
  void dispose() {
    _runnerNumberController.dispose();
    _chipIdController.dispose();
    super.dispose();
  }

  String _getTicketStatusText(bool isCheckedIn) {
    // Verificar si el ticket ya fue validado
    if (widget.ticket.ticketStatus == 'validated') {
      final validatedDate = widget.ticket.validatedAt;
      if (validatedDate != null) {
        return '✓ Ticket validado el ${_formatDateTime(validatedDate)}';
      }
      return '✓ Ticket ya validado';
    }
    if (isCheckedIn) {
      return '✓ Ticket ya registrado';
    }
    if (widget.ticket.ticketStatus == 'valid' || widget.ticket.isValid) {
      return '✓ Ticket válido, listo para usar';
    }
    return '✗ Ticket no válido';
  }

  Color _getStatusColor(bool isCheckedIn) {
    if (widget.ticket.ticketStatus == 'validated') {
      return AppColors.info;
    }
    if (isCheckedIn) {
      return AppColors.info;
    }
    if (widget.ticket.ticketStatus == 'valid' || widget.ticket.isValid) {
      return AppColors.success;
    }
    return AppColors.error;
  }

  Color _getStatusBackgroundColor(bool isCheckedIn) {
    if (widget.ticket.ticketStatus == 'validated') {
      return AppColors.info.withValues(alpha: 0.2);
    }
    if (isCheckedIn) {
      return AppColors.info.withValues(alpha: 0.2);
    }
    if (widget.ticket.ticketStatus == 'valid' || widget.ticket.isValid) {
      return AppColors.success.withValues(alpha: 0.2);
    }
    return AppColors.error.withValues(alpha: 0.2);
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final month = months[dateTime.month - 1];
    return '${dateTime.day} de $month de ${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String ticketName =
        (widget.ticket.ticketName == null || widget.ticket.ticketName!.isEmpty)
        ? 'N/A'
        : widget.ticket.ticketName!;
    String participantStatus =
        (widget.ticket.participantStatus == null ||
            widget.ticket.participantStatus!.isEmpty)
        ? 'N/A'
        : (widget.ticket.participantStatus == 'active' ? 'Activo' : 'Inactivo');
    String purchaseDateStr = widget.ticket.purchaseDate != null
        ? _formatDateTime(widget.ticket.purchaseDate)
        : (widget.ticket.validatedAt != null
              ? _formatDateTime(widget.ticket.validatedAt)
              : 'N/A');

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estado del Ticket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.ticket.participantStatus == 'active'
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.ticket.participantStatus == 'active'
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.ticket.participantStatus == 'active'
                        ? 'Activo'
                        : 'Inactivo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.ticket.participantStatus == 'active'
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Evento
                _buildSection(label: 'Evento', value: widget.ticket.eventName),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Información del ticket (Grid)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSection(
                        label: 'Nombre Ticket',
                        value: ticketName,
                        isBold: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSection(
                        label: 'Categoría',
                        value: widget.ticket.categoryName,
                        isBold: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Correlativo y Ticket ID
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildSectionWithIcon(
                        label: 'Correlativo',
                        value: (widget.ticket.ticketCorrelative ?? 0)
                            .toString(),
                        icon: Icons.numbers,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSectionWithIcon(
                        label: 'Ticket ID',
                        value: widget.ticket.validationCode ?? 'N/A',
                        icon: Icons.confirmation_number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Inputs editables
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'Número de Corredor',
                        controller: _runnerNumberController,
                        icon: Icons.numbers,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Chip ID',
                        controller: _chipIdController,
                        icon: Icons.security,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Información del participante
                _buildSection(
                  label: 'Participante',
                  value: widget.ticket.participantName,
                  icon: Icons.person,
                  isBold: true,
                ),
                const SizedBox(height: 12),

                _buildSection(
                  label: 'Documento',
                  value:
                      '${widget.ticket.participantDocumentType ?? ''}: ${widget.ticket.participantDocumentNumber ?? ''}',
                  isBold: false,
                ),
                const SizedBox(height: 12),

                _buildBadgeSection(
                  label: 'Estado Participante',
                  value: participantStatus,
                  isActive: widget.ticket.participantStatus == 'active',
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Estado del ticket y fecha
                _buildStatusBox(
                  status: _getTicketStatusText(false),
                  backgroundColor: _getStatusBackgroundColor(false),
                  textColor: _getStatusColor(false),
                ),
                const SizedBox(height: 16),

                _buildSection(
                  label: 'Fecha de Compra',
                  value: purchaseDateStr,
                  icon: Icons.calendar_today,
                  isBold: false,
                ),
              ],
            ),
          ),

          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.isSaving
                            ? null
                            : () => widget.onSaveData(
                                _runnerNumberController.text,
                                _chipIdController.text,
                              ),
                        icon: widget.isSaving
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: const Text(
                          'Guardar Datos',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: widget.isSaving ? null : widget.onNewScan,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Text('Nuevo Escaneo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required String value,
    IconData? icon,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        if (icon != null)
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildSectionWithIcon({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBadgeSection({
    required String label,
    required String value,
    required bool isActive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBox({
    required String status,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: textColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
