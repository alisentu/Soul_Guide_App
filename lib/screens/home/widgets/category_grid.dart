import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';

/// 4-column category icon grid
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'label': 'Diziler',
        'icon': Icons.movie_rounded,
        'bgColor': AppColors.primaryContainer.withValues(alpha: 0.2),
        'iconColor': AppColors.primary,
        'route': '/category/series',
      },
      {
        'label': 'Oyunlar',
        'icon': Icons.sports_esports_rounded,
        'bgColor': AppColors.secondaryContainer.withValues(alpha: 0.3),
        'iconColor': AppColors.secondary,
        'route': '/category/games',
      },
      {
        'label': 'Kitaplar',
        'icon': Icons.menu_book_rounded,
        'bgColor': AppColors.tertiaryContainer.withValues(alpha: 0.2),
        'iconColor': AppColors.tertiary,
        'route': '/category/books',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories.map((cat) {
        return _CategoryItem(
          label: cat['label'] as String,
          icon: cat['icon'] as IconData,
          bgColor: cat['bgColor'] as Color,
          iconColor: cat['iconColor'] as Color,
          route: cat['route'] as String,
        );
      }).toList(),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String route;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.route,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push(widget.route);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pressed
                    ? widget.bgColor.withValues(alpha: 0.8)
                    : widget.bgColor,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
