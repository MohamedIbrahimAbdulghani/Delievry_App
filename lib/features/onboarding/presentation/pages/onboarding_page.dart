import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../di/injection_container.dart';
import '../bloc/onboarding_bloc.dart';
import 'package:delievry_app/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final List<Map<String, String>> _onboardingData = [
      {
        'title': localizations?.onboardingTitle1 ?? 'Discover Gourmet Food',
        'description': localizations?.onboardingDesc1 ?? 'Explore the best restaurants and premium food near you.',
      },
      {
        'title': localizations?.onboardingTitle2 ?? 'Fast Delivery',
        'description': localizations?.onboardingDesc2 ?? 'Get your favorite food delivered directly to your doorstep.',
      },
      {
        'title': localizations?.onboardingTitle3 ?? 'Live Tracking',
        'description': localizations?.onboardingDesc3 ?? 'Track your order in real-time on a premium map.',
      },
    ];
    return BlocProvider(
      create: (_) => sl<OnboardingBloc>(),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            context.go('/login');
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          context.read<OnboardingBloc>().add(CompleteOnboarding());
                        },
                        child: Text(localizations?.skip ?? 'Skip', style: const TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _onboardingData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.fastfood, size: 200, color: AppColors.primary),
                                const SizedBox(height: 48),
                                Text(
                                  _onboardingData[index]['title']!,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _onboardingData[index]['description']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => buildDot(index, context),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: BlocBuilder<OnboardingBloc, OnboardingState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            text: _currentPage == _onboardingData.length - 1 ? (localizations?.getStarted ?? 'Get Started') : (localizations?.continueText ?? 'Continue'),
                            onPressed: () {
                              if (_currentPage == _onboardingData.length - 1) {
                                context.read<OnboardingBloc>().add(CompleteOnboarding());
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index ? AppColors.primary : AppColors.outline,
      ),
    );
  }
}
