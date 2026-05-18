import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/user_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_card.dart';

/// giri_ekran_g_rsel_bur_se_imi - Onboarding Form Screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedZodiac;
  final Set<String> _selectedFocusAreas = {};

  final List<Map<String, dynamic>> _zodiacs = [
    {'name': 'Koç', 'symbol': '♈'},
    {'name': 'Boğa', 'symbol': '♉'},
    {'name': 'İkizler', 'symbol': '♊'},
    {'name': 'Yengeç', 'symbol': '♋'},
    {'name': 'Aslan', 'symbol': '♌'},
    {'name': 'Başak', 'symbol': '♍'},
    {'name': 'Terazi', 'symbol': '♎'},
    {'name': 'Akrep', 'symbol': '♏'},
    {'name': 'Yay', 'symbol': '♐'},
    {'name': 'Oğlak', 'symbol': '♑'},
    {'name': 'Kova', 'symbol': '♒'},
    {'name': 'Balık', 'symbol': '♓'},
  ];

  final List<String> _focusOptions = [
    'Maneviyat', 'Kariyer', 'İlişkiler', 'Huzur',
    'Sağlık', 'Sanat', 'Spor', 'Teknoloji',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen adınızı girin.')),
      );
      return;
    }

    await ref.read(userProfileProvider.notifier).createProfile(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text),
          zodiacSign: _selectedZodiac,
          focusAreas: _selectedFocusAreas.toList(),
        );

    if (mounted) {
      context.go('/quiz');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Aura background accents
          Positioned(
            top: -80,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixedDim.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'SoulGuide',
                          style: AppTypography.headlineXl.copyWith(
                            color: AppColors.primaryFixedDim,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(
                          'Kendi yolculuğunu keşfetmeye hazır mısın?\nSana özel bir deneyim için seni tanıyalım.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Name input
                  _buildLabel('Adın veya Takma Adın'),
                  const SizedBox(height: AppSpacing.stackSm),
                  _buildInput(
                    controller: _nameController,
                    hint: 'Nasıl hitap edelim?',
                    id: 'name_input',
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Age input
                  _buildLabel('Yaşın'),
                  const SizedBox(height: AppSpacing.stackSm),
                  _buildInput(
                    controller: _ageController,
                    hint: '25',
                    keyboardType: TextInputType.number,
                    id: 'age_input',
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Zodiac selection
                  _buildLabel('Burcun'),
                  const SizedBox(height: AppSpacing.stackMd),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: AppSpacing.stackSm,
                      crossAxisSpacing: AppSpacing.stackSm,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _zodiacs.length,
                    itemBuilder: (context, i) {
                      final zodiac = _zodiacs[i];
                      final isSelected = _selectedZodiac == zodiac['name'];
                      return GestureDetector(
                        onTap: () => setState(
                          () => _selectedZodiac = zodiac['name'] as String,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.secondaryContainer.withValues(alpha: 0.5)
                                : AppColors.surfaceContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary.withValues(alpha: 0.5)
                                  : AppColors.outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    zodiac['symbol'] as String,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: isSelected
                                          ? AppColors.secondary
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    zodiac['name'] as String,
                                    style: AppTypography.labelCaps.copyWith(
                                      fontSize: 10,
                                      color: isSelected
                                          ? AppColors.secondary
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.stackLg),

                  // Focus area chips
                  _buildLabel('Odak Noktan'),
                  const SizedBox(height: AppSpacing.stackMd),
                  Wrap(
                    spacing: AppSpacing.stackSm,
                    runSpacing: AppSpacing.stackSm,
                    children: _focusOptions.map((opt) {
                      final isSelected = _selectedFocusAreas.contains(opt);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selectedFocusAreas.remove(opt);
                          } else {
                            _selectedFocusAreas.add(opt);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.gutter,
                            vertical: AppSpacing.stackSm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.secondaryContainer
                                : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            opt,
                            style: AppTypography.labelLg.copyWith(
                              color: isSelected
                                  ? AppColors.onSecondaryContainer
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // CTA Button
                  GradientButton(
                    label: 'Başla',
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryFixedDim, AppColors.primaryContainer],
                    ),
                    textColor: AppColors.onPrimaryFixed,
                    height: 60,
                    onTap: _handleStart,
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Center(
                    child: Text(
                      'Devam ederek Kullanım Koşullarını ve\nGizlilik Politikasını kabul etmiş olursunuz.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.outline.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: AppTypography.labelLg.copyWith(color: AppColors.onSurface),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required String id,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      key: Key(id),
      controller: controller,
      keyboardType: keyboardType,
      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
          borderSide: const BorderSide(
            color: AppColors.primaryFixedDim,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.stackMd,
        ),
        hintStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.outline.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
