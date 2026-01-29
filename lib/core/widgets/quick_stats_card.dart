import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget de estadísticas rápidas estilo tocke-app-2026
/// Muestra métricas principales en un diseño de grid
class QuickStatsCard extends StatelessWidget {
  final int eventsCount;
  final int scannedCount;
  final int todayCount;

  const QuickStatsCard({
    super.key,
    required this.eventsCount,
    required this.scannedCount,
    required this.todayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatItem('Eventos', eventsCount),
          Container(
            width: 1,
            height: 60,
            color: AppColors.border.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildStatItem('Escaneados', scannedCount),
          Container(
            width: 1,
            height: 60,
            color: AppColors.border.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildStatItem('Hoy', todayCount),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
