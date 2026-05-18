import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/quiz_question.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/skeleton_loader.dart';

/// quiz_ekran_soft_pastel - Quiz/Test ekranı
class QuizScreen extends ConsumerStatefulWidget {
  final bool isWeekly;
  const QuizScreen({super.key, this.isWeekly = false});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideIn;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuint));
    _fadeIn = CurvedAnimation(parent: _slideController, curve: Curves.easeOut);
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _animateToNext() {
    _slideController.reset();
    _slideController.forward();
  }

  Future<void> _handleComplete() async {
    await ref.read(quizSessionProvider.notifier).completeSession();
    if (!mounted) return;

    final storage = ref.read(storageServiceProvider);
    if (!storage.isOnboardingComplete) {
      await storage.setOnboardingComplete();
    }
    if (widget.isWeekly) {
      await storage.setLastWeeklyTestDate(DateTime.now());
    }

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = widget.isWeekly
        ? ref.watch(weeklyQuestionsProvider)
        : ref.watch(onboardingQuestionsProvider);

    return questionsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              children: [
                const SkeletonCard(height: 60),
                const SizedBox(height: AppSpacing.stackLg),
                const SkeletonCard(height: 160),
                const SizedBox(height: AppSpacing.stackMd),
                const SkeletonList(count: 3, cardHeight: 80),
              ],
            ),
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: ErrorStateWidget(
          message: 'Sorular yüklenirken hata oluştu:\n$e',
          onRetry: () {
            if (widget.isWeekly) {
              ref.refresh(weeklyQuestionsProvider);
            } else {
              ref.refresh(onboardingQuestionsProvider);
            }
          },
        ),
      ),
      data: (questions) {
        // Load into session on first data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final session = ref.read(quizSessionProvider);
          if (session.questions.isEmpty) {
            ref.read(quizSessionProvider.notifier).loadQuestions(questions);
          }
        });

        return Consumer(
          builder: (context, ref, _) {
            final session = ref.watch(quizSessionProvider);
            final question = session.currentQuestion;

            if (question == null) return const SizedBox.shrink();
            if (session.isCompleted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/home');
              });
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              body: Stack(
                children: [
                  // Ambient background
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 265,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Header & progress
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.marginMobile,
                            AppSpacing.stackMd,
                            AppSpacing.marginMobile,
                            0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildIconBtn(
                                    icon: Icons.arrow_back_rounded,
                                    onTap: session.hasPrev
                                        ? () {
                                            ref
                                                .read(quizSessionProvider.notifier)
                                                .prevQuestion();
                                            _animateToNext();
                                          }
                                        : () => context.pop(),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          widget.isWeekly
                                              ? 'Haftalık Test'
                                              : 'Aura Journey',
                                          style: AppTypography.labelCaps.copyWith(
                                            color: AppColors.onSurfaceVariant
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Adım ${session.currentIndex + 1} / ${session.questions.length}',
                                          style: AppTypography.bodyMd.copyWith(
                                            color: AppColors.primaryFixedDim,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildIconBtn(
                                    icon: Icons.close_rounded,
                                    onTap: () => context.go('/home'),
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.stackMd),
                              GradientProgressBar(
                                value: session.progress,
                                height: 6,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.tertiaryFixedDim,
                                    AppColors.tertiary,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Question area
                        Expanded(
                          child: SlideTransition(
                            position: _slideIn,
                            child: FadeTransition(
                              opacity: _fadeIn,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.marginMobile,
                                  vertical: AppSpacing.stackLg,
                                ),
                                child: Column(
                                  children: [
                                    // Question icon
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.surfaceContainerHigh,
                                        border: Border.all(
                                          color: AppColors.outline.withValues(alpha: 0.1),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.05),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _getIcon(question.icon),
                                        color: AppColors.primaryFixed,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.gutter),
                                    Text(
                                      question.question,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.headlineXl.copyWith(
                                        color: AppColors.primaryFixed,
                                        fontSize: 28,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    if (question.subtitle != null) ...[
                                      const SizedBox(height: AppSpacing.stackSm),
                                      Text(
                                        question.subtitle!,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.bodyMd.copyWith(
                                          color: AppColors.onSurfaceVariant
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: AppSpacing.stackLg),
                                    // Options
                                    ...question.options.asMap().entries.map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppSpacing.stackMd,
                                        ),
                                        child: _OptionCard(
                                          option: entry.value,
                                          colorIndex: entry.key,
                                          isSelected: session.selectedOptionId ==
                                              entry.value.id,
                                          onTap: () {
                                            ref
                                                .read(quizSessionProvider.notifier)
                                                .selectOption(question.id, entry.value.id);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Bottom action
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.marginMobile,
                            0,
                            AppSpacing.marginMobile,
                            AppSpacing.gutter,
                          ),
                          child: GradientButton(
                            label: session.hasNext ? 'Sonraki Soru' : 'Tamamla',
                            isLoading: session.isLoading,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryContainer,
                                AppColors.secondaryContainer,
                              ],
                            ),
                            textColor: AppColors.onPrimaryContainer,
                            icon: Icon(
                              session.hasNext
                                  ? Icons.arrow_forward_rounded
                                  : Icons.check_rounded,
                              color: AppColors.onPrimaryContainer,
                            ),
                            onTap: session.selectedOptionId == null
                                ? null
                                : session.hasNext
                                    ? () {
                                        ref
                                            .read(quizSessionProvider.notifier)
                                            .nextQuestion();
                                        _animateToNext();
                                      }
                                    : _handleComplete,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.onSurfaceVariant,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainer.withValues(alpha: 0.5),
          border: Border.all(
            color: AppColors.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'routine': return Icons.self_improvement_rounded;
      case 'weekend': return Icons.weekend_rounded;
      case 'hiking': return Icons.hiking_rounded;
      case 'group': return Icons.group_rounded;
      case 'menu_book': return Icons.menu_book_rounded;
      case 'music_note': return Icons.music_note_rounded;
      case 'psychology': return Icons.psychology_rounded;
      case 'sports_esports': return Icons.sports_esports_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}

class _OptionCard extends StatelessWidget {
  final QuizOption option;
  final int colorIndex;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.colorIndex,
    required this.isSelected,
    required this.onTap,
  });

  Color get _accentColor {
    switch (colorIndex % 3) {
      case 0: return AppColors.tertiary;
      case 1: return AppColors.primary;
      case 2: return AppColors.secondary;
      default: return AppColors.primary;
    }
  }

  Color get _containerColor {
    switch (colorIndex % 3) {
      case 0: return AppColors.tertiaryContainer;
      case 1: return AppColors.primaryContainer;
      case 2: return AppColors.secondaryContainer;
      default: return AppColors.primaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(AppSpacing.gutter),
        decoration: BoxDecoration(
          color: isSelected
              ? _containerColor.withValues(alpha: 0.15)
              : AppColors.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected
                ? _accentColor.withValues(alpha: 0.5)
                : _accentColor.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _containerColor.withValues(
                  alpha: isSelected ? 0.4 : 0.15,
                ),
                border: Border.all(
                  color: _accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                _getIcon(option.icon),
                color: isSelected ? _accentColor : AppColors.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.text,
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: isSelected ? _accentColor : AppColors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _accentColor : AppColors.outline.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accentColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'self_improvement': return Icons.self_improvement_rounded;
      case 'bolt': return Icons.bolt_rounded;
      case 'auto_awesome': return Icons.auto_awesome_rounded;
      case 'menu_book': return Icons.menu_book_rounded;
      case 'music_note': return Icons.music_note_rounded;
      case 'hiking': return Icons.hiking_rounded;
      case 'group': return Icons.group_rounded;
      default: return Icons.circle_outlined;
    }
  }
}
