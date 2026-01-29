import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget de navegación inferior estilo tocke-app-2026
/// Proporciona navegación con 3 pestañas principales
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      BottomNavItem(
        icon: Icons.calendar_today,
        label: 'Eventos',
      ),
      BottomNavItem(
        icon: Icons.qr_code_scanner,
        label: 'Escanear',
      ),
      BottomNavItem(
        icon: Icons.history,
        label: 'Historial',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                item: items[index],
                isActive: index == currentIndex,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                item.icon,
                size: 24,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 32,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}
