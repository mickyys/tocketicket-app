import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget de navegación inferior estilo tocke-app-2026
/// Proporciona navegación con 3 pestañas principales
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool canValidate;
  final List<BottomNavItem> items;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.canValidate = true,
    this.items = const [
      BottomNavItem(icon: Icons.qr_code_scanner, label: 'Escanear'),
      BottomNavItem(icon: Icons.history, label: 'Historial'),
    ],
  });

  List<BottomNavItem> get _filteredItems {
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              filteredItems.length,
              (index) => _buildNavItem(
                item: filteredItems[index],
                isActive: index == currentIndex,
                onTap: () {
                  if (canValidate) {
                    onTap(index);
                  } else {
                    onTap(1);
                  }
                },
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
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 24,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Opacity(
                opacity: isActive ? 1 : 0,
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
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({required this.icon, required this.label});
}
