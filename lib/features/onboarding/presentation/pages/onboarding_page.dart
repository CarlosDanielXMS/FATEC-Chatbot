import 'package:chatbot/app/app_initializer.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/features/onboarding/domain/entities/onboarding_item.dart';
import 'package:chatbot/features/onboarding/presentation/widgets/onboarding_footer.dart';
import 'package:chatbot/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:chatbot/features/onboarding/presentation/widgets/onboarding_reveal_overlay.dart';
import 'package:chatbot/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  final _startButtonKey = GlobalKey();

  late final AnimationController _revealController;
  late final Animation<double> _revealProgress;

  int _currentIndex = 0;
  Offset _revealOrigin = Offset.zero;
  bool _isRevealing = false;

  static const _items = [
    OnboardingItem(
      title: 'Bem vindo ao Be Value!',
      description:
          'Aqui, você tem o controle dos seus medicamentos e cuidado personalizado. Vamos começar?',
      imagePath:
          'assets/images/jovens-de-design-plano-ajudando-a-ilustracao-de-idosos.png',
      imageHeight: 364,
    ),
    OnboardingItem(
      title: 'Organize seus medicamentos',
      description:
          'Cadastre seus remédios, horários e doses. Assim, você nunca mais vai esquecer uma medicação importante.',
      imagePath: 'assets/images/medicamentos.png',
      imageHeight: 364,
    ),
    OnboardingItem(
      title: 'Receba lembretes inteligentes',
      description:
          'Ative notificações para ser avisado nos horários certos. Quando tocar, é só tocar em “Tomei” e pronto!',
      imagePath: 'assets/images/notification.png',
      imageHeight: 364,
    ),
    OnboardingItem(
      title: 'Cuide da sua saúde com apoio profissional',
      description:
          'Compartilhe seu histórico com um profissional de saúde para um acompanhamento ainda mais especializado.',
      imagePath: 'assets/images/doctor.png',
      imageHeight: 364,
    ),
  ];

  bool get _isLastPage => _currentIndex == _items.length - 1;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );

    _revealProgress = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _goToNextPage() async {
    if (_isLastPage) {
      await _finishOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: AppDurations.normal,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _skipToLastPage() async {
    await _pageController.animateToPage(
      _items.length - 1,
      duration: AppDurations.normal,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    _captureRevealOrigin();

    setState(() {
      _isRevealing = true;
    });

    await _revealController.forward();

    await AppInitializer.navigationState.completeOnboarding();
  }

  void _captureRevealOrigin() {
    final renderBox =
        _startButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) {
      final mediaQuery = MediaQuery.of(context);

      _revealOrigin = Offset(
        mediaQuery.size.width / 2,
        mediaQuery.size.height - AppSpacing.s80,
      );
      return;
    }

    final topLeft = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _revealOrigin = Offset(
      topLeft.dx + size.width / 2,
      topLeft.dy + size.height / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.s32),
                  const OnboardingHeader(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (_, index) {
                        return OnboardingSlide(
                          item: _items[index],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.s12,
                      right: AppSpacing.s12,
                      bottom: AppSpacing.s24,
                    ),
                    child: OnboardingFooter(
                      length: _items.length,
                      currentIndex: _currentIndex,
                      onNextPressed: _goToNextPage,
                      onStartPressed: _finishOnboarding,
                      onSkipPressed: _skipToLastPage,
                      isLastPage: _isLastPage,
                      startButtonKey: _startButtonKey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isRevealing)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _revealProgress,
                builder: (_, _) {
                  return OnboardingRevealOverlay(
                    progress: _revealProgress.value,
                    origin: _revealOrigin,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}