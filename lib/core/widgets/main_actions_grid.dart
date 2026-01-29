import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget de acciones principales estilo tocke-app-2026
/// Muestra 2 botones grandes de acciones principales
class MainActionsGrid extends StatelessWidget {
  final VoidCallback? onScanPress;
  final VoidCallback? onHistoryPress;

  const MainActionsGrid({
    super.key,
    this.onScanPress,
    this.onHistoryPress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón Escanear QR
        Expanded(
          child: GestureDetector(
            onTap: onScanPress,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onScanPress,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 32,
                        color: AppColors.textOnPrimary,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Escanear QR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón Historial
        Expanded(
          child: GestureDetector(
            onTap: onHistoryPress,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onHistoryPress,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Historial',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
