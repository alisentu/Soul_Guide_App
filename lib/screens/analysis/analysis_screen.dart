import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/analysis_data.dart';
import '../../providers/analysis_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/radar_chart.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/bottom_nav_bar.dart';

/// analiz_ekran_soft_pastel - Analiz ekranı
class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analysisProvider.notifier).generateAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysisAsync = ref.watch(analysisProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1.0, -1.0),
                radius: 1.5,
                colors: [Color(0x660C3254), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: analysisAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  children: [
                    SkeletonCard(height: 400),
                    SizedBox(height: AppSpacing.stackMd),
                    SkeletonCard(height: 120),
                    SizedBox(height: AppSpacing.stackMd),
                    SkeletonCard(height: 120),
                  ],
                ),
              ),
              error: (e, _) => ErrorStateWidget(
                message: e.toString(),
                onRetry: () =>
                    ref.read(analysisProvider.notifier).generateAnalysis(),
              ),
              data: (data) {
                if (data == null) return const SizedBox.shrink();
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile,
                    AppSpacing.stackSm,
                    AppSpacing.marginMobile,
                    100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Senin\nAnalizin',
                        style: AppTypography.headlineXl.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Text(
                        'Cevaplarına dayalı gerçek zamanlı kişilik yansıması.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackLg),

                      // Bento Grid: Radar + Stats
                      LayoutBuilder(builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _RadarCard(data: data)),
                              const SizedBox(width: AppSpacing.gutter),
                              Expanded(
                                child: Column(
                                  children: data.dimensions
                                      .take(2)
                                      .map((d) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: AppSpacing.gutter),
                                            child: _StatCard(dimension: d),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _RadarCard(data: data),
                            const SizedBox(height: AppSpacing.gutter),
                            ...data.dimensions.map((d) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.stackMd),
                                  child: _StatCard(dimension: d),
                                )),
                          ],
                        );
                      }),

                      const SizedBox(height: AppSpacing.gutter),

                      // Insight + Tip row
                      _InsightCard(data: data),
                      const SizedBox(height: AppSpacing.gutter),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 3),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.8),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.stackSm,
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                const Expanded(
                  child: Center(
                    child: Text(
                      'SoulGuide',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarCard extends StatelessWidget {
  final AnalysisData data;
  const _RadarCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: AppColors.glassCardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassCardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kişilik\nAnalizi',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.onSurface,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'Haftalık rezonans analizi',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.stackMd,
                  vertical: AppSpacing.stackSm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bu Hafta',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more_rounded,
                        color: AppColors.onSurfaceVariant, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackLg),
          RadarChart(dimensions: data.dimensions, size: 240),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final RadarDimension dimension;
  const _StatCard({required this.dimension});

  Color get _trendColor =>
      dimension.value > 0.6 ? AppColors.tertiary : AppColors.error;

  @override
  Widget build(BuildContext context) {
    final colorHex = dimension.color.replaceAll('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.gutter),
      decoration: BoxDecoration(
        color: AppColors.glassCardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.auto_graph_rounded, color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.stackSm),
              Text(dimension.label,
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(dimension.value * 100).toInt()}%',
                style: AppTypography.headlineXl.copyWith(color: color, fontSize: 36),
              ),
              const SizedBox(width: AppSpacing.stackSm),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      dimension.value > 0.6
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: _trendColor,
                      size: 16,
                    ),
                    Text(
                      dimension.value > 0.6 ? '+5%' : '-2%',
                      style: AppTypography.bodySm.copyWith(color: _trendColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSm),
          GradientProgressBar(
            value: dimension.value,
            height: 6,
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.5), color],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final AnalysisData data;
  const _InsightCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: AppColors.glassCardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: AppColors.secondary, size: 28),
              const SizedBox(width: AppSpacing.stackSm),
              Text('Günlük İçgörü',
                  style: AppTypography.headlineLg
                      .copyWith(color: AppColors.onSurface, fontSize: 22)),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Text(
            data.insight,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Wrap(
            spacing: AppSpacing.stackSm,
            runSpacing: AppSpacing.stackSm,
            children: data.insightTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.stackMd, vertical: AppSpacing.unit),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.2)),
                ),
                child: Text(tag,
                    style: AppTypography.labelCaps
                        .copyWith(color: AppColors.secondary)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
