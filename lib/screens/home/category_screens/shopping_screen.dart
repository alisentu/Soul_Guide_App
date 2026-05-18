import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/product.dart';
import '../../../providers/recommendations_provider.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Alışveriş',
            style: AppTypography.headlineLgMobile
                .copyWith(color: AppColors.onSurface)),
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Text(
              'Ürünler yüklenirken hata oluştu: $error',
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text(
                'Sana uygun ürün bulamadık.',
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.stackMd,
                  AppSpacing.marginMobile,
                  AppSpacing.stackSm,
                ),
                child: Text(
                  'Profil analizine göre Trendyol\'dan özel seçimler',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.stackMd),
                  itemBuilder: (_, i) => _ProductCard(product: products[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
            child: Image.network(
              product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.local_mall_rounded,
                    color: AppColors.primaryFixedDim),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.brand != null)
                  Text(product.brand!,
                      style: AppTypography.labelCaps
                          .copyWith(color: AppColors.primaryFixedDim)),
                Text(product.name,
                    style: AppTypography.headlineSm
                        .copyWith(color: AppColors.onSurface, fontSize: 15)),
                const SizedBox(height: 4),
                Text(product.description,
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(product.formattedPrice,
                        style: AppTypography.headlineSm
                            .copyWith(color: AppColors.tertiary, fontSize: 16)),
                    if (product.rating != null) ...[
                      const Spacer(),
                      Text('⭐ ${product.rating!.toStringAsFixed(1)}',
                          style: AppTypography.labelSm),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.stackSm),
          GestureDetector(
            onTap: () {
              if (product.purchaseUrl != null) {
                launchUrl(Uri.parse(product.purchaseUrl!),
                    mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.stackSm),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.open_in_new_rounded,
                  color: AppColors.primaryFixedDim, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
