import 'package:chatbot/app/app_initializer.dart';
import 'package:chatbot/features/splash/presentation/widgets/splash_gradient_background.dart';
import 'package:chatbot/features/splash/presentation/widgets/splash_logo_lockup.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _beOffsetX;
  late final Animation<double> _valueOffsetX;
  late final Animation<double> _revealProgress;

  static const _totalDuration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );

    _logoScale = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.10,
          0.54,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _beOffsetX = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.10,
          0.40,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _valueOffsetX = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.10,
          0.40,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _revealProgress = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.66,
          0.92,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        AppInitializer.navigationState.completeSplash();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return SplashGradientBackground(
            revealProgress: _revealProgress.value,
            child: Center(
              child: SplashLogoLockup(
                logoScale: _logoScale.value,
                beOffsetFactor: _beOffsetX.value,
                valueOffsetFactor: _valueOffsetX.value,
                screenWidth: screenWidth,
              ),
            ),
          );
        },
      ),
    );
  }
}