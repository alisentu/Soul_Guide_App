import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/gradient_button.dart';

/// kar_lama_ekran_soft_pastel - Welcome / Splash Screen
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _fadeIn;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _glowPulse = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Radial gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-1.0, -1.0),
                radius: 1.8,
                colors: [Color(0x660C3254), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  // Top App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                      vertical: AppSpacing.stackMd,
                    ),
                    child: Text(
                      'SoulGuide',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppSpacing.stackLg),
                          // Abstract visual with glow
                          AnimatedBuilder(
                            animation: _glowPulse,
                            builder: (context, child) {
                              return Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryContainer
                                          .withValues(alpha: 0.1 + 0.05 * _glowPulse.value),
                                      blurRadius: 60 + 20 * _glowPulse.value,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primaryContainer.withValues(alpha: 0.08),
                                      AppColors.secondaryContainer.withValues(alpha: 0.04),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primaryFixedDim.withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 56,
                                      color: AppColors.primaryFixedDim
                                          .withValues(alpha: 0.6 + 0.2 * _glowPulse.value),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.stackLg),
                          // Typography
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.marginMobile,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Kişiselleştirilmiş\nArama',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.headlineLg.copyWith(
                                    color: AppColors.onSurface,
                                    letterSpacing: -1,
                                    fontSize: 36,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.stackMd),
                                Text(
                                  'SoulGuide ile kendinizi keşfedin, günlük analizlerle ruh halinizi takip edin ve size özel önerilerle gelişin.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.stackLg),
                        ],
                      ),
                    ),
                  ),
                  // Bottom action area
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.marginMobile,
                      0,
                      AppSpacing.marginMobile,
                      AppSpacing.gutter,
                    ),
                    child: Column(
                      children: [
                        GradientButton(
                          label: 'Devam Et',
                          gradient: AppColors.primaryGradient,
                          textColor: AppColors.onPrimaryFixed,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.onPrimaryFixed,
                          ),
                          onTap: () => context.go('/onboarding'),
                        ),
                        const SizedBox(height: AppSpacing.stackMd),
                        Text(
                          'Devam ederek Kullanım Koşullarını kabul etmiş olursunuz.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.outline.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
