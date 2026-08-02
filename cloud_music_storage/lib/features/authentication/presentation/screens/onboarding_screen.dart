/// Onboarding screen.
///
/// Three-page intro showcasing key features before auth.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.cloud_upload_rounded,
      title: 'Upload Your Music',
      description:
          'Store your entire music collection in the cloud. MP3, FLAC, WAV — we support them all.',
      gradient: LinearGradient(
        colors: [Color(0xFF2E6BFF), Color(0xFF5A8FFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _OnboardingPage(
      icon: Icons.headphones_rounded,
      title: 'Stream Anywhere',
      description:
          'Listen on any device — phone, tablet, desktop, or web. Your library follows you everywhere.',
      gradient: LinearGradient(
        colors: [Color(0xFFFF6B4A), Color(0xFFFF8F73)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _OnboardingPage(
      icon: Icons.offline_pin_rounded,
      title: 'Go Offline',
      description:
          'Download tracks for offline listening. Perfect for commutes, flights, and places without signal.',
      gradient: LinearGradient(
        colors: [Color(0xFF2ECC71), Color(0xFF6EE7A0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    ref.read(onboardingCompleteProvider.notifier).state = true;
    context.go(RoutePaths.login);
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.pageTransition,
        curve: AppAnimations.pageCurve,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTypography.bodyMedium(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: page.gradient,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: (page.gradient as LinearGradient)
                                    .colors
                                    .first
                                    .withValues(alpha: 0.3),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          style: AppTypography.h1(
                            color: context.appColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description,
                          style: AppTypography.body(
                            color: context.appColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return AnimatedContainer(
                        duration: AppAnimations.short,
                        curve: AppAnimations.defaultCurve,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : context.appColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;
}
