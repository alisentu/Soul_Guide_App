import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.explore_rounded, 'label': 'Keşfet', 'route': '/home'},
      {'icon': Icons.search_rounded, 'label': 'Ara', 'route': '/search'},
      {'icon': Icons.psychology_rounded, 'label': 'Testler', 'route': '/tests'},
      {'icon': Icons.analytics_rounded, 'label': 'Analiz', 'route': '/analysis'},
      {'icon': Icons.person_rounded, 'label': 'Profil', 'route': '/profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () { if (!isActive) context.go(item['route'] as String); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd, vertical: AppSpacing.stackSm),
                  decoration: isActive
                      ? BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item['icon'] as IconData,
                          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant, size: 22),
                      const SizedBox(height: 2),
                      Text(item['label'] as String,
                          style: AppTypography.labelCaps.copyWith(
                              fontSize: 10,
                              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
