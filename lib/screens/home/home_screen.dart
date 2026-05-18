import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/user_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'widgets/weekly_task_card.dart';
import 'widgets/category_grid.dart';
import 'widgets/daily_picks_section.dart';

/// Ana Menü - ana_ekran_soft_pastel + ana_ekran_modern birleşimi
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, profile?.name ?? 'Kullanıcı'),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1.0, -1.0),
                radius: 1.5,
                colors: [Color(0x26416086), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.refresh(moviesProvider);
                ref.refresh(gamesProvider);
                ref.refresh(booksProvider);
              },
              color: AppColors.primaryFixedDim,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekly task card (Gemini)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                      ),
                      child: WeeklyTaskCard(
                        onStartTest: () {
                          ref.read(quizSessionProvider.notifier).reset();
                          context.push('/weekly-quiz');
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                      ),
                      child: _SearchBar(),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),

                    // Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                      ),
                      child: Text(
                        'Kategoriler',
                        style: AppTypography.headlineLgMobile.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                      ),
                      child: CategoryGrid(),
                    ),
                    const SizedBox(height: AppSpacing.stackLg),

                    // Daily picks
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Senin İçin Seçtiklerimiz',
                              style: AppTypography.headlineLgMobile.copyWith(
                                color: AppColors.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Tümünü Gör',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    const DailyPicksSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String name) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.8),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    'SoulGuide',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.stackMd),
            child:
                Icon(Icons.search_rounded, color: AppColors.outline, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Ne keşfetmek istersiniz?',
                hintStyle:
                    AppTypography.bodyMd.copyWith(color: AppColors.outline),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.push('/search', extra: query);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
