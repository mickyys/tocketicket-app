import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget de tarjeta de evento estilo EventsDashboard.tsx (tocke-app-2026)
/// Diseño mejorado siguiendo el estilo del componente React
class EventCard extends StatelessWidget {
  final String eventName;
  final String date;
  final String location;
  final int totalTickets;
  final String? badgeText;
  final VoidCallback? onTap;
  final bool active;

  const EventCard({
    super.key,
    required this.eventName,
    required this.date,
    required this.location,
    required this.totalTickets,
    this.badgeText,
    this.onTap,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Nombre del evento, badge y chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Columna izquierda: Nombre y badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del evento
                            Text(
                              eventName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Badge de estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText ?? (active ? 'Activo' : 'Inactivo'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Icono chevron derecha
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Información del evento
                  _buildInfoRow(Icons.calendar_today, date),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, location),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.people, '$totalTickets entradas'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
