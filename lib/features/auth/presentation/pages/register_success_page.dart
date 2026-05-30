import 'dart:async';

import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterSuccessPage extends StatefulWidget {
  const RegisterSuccessPage({super.key});

  @override
  State<RegisterSuccessPage> createState() => _RegisterSuccessPageState();
}

class _RegisterSuccessPageState extends State<RegisterSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;

  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _iconScale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1,
            end: 1.10,
          ).chain(
            CurveTween(curve: Curves.easeOut),
          ),
          weight: 45,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.10,
            end: 1,
          ).chain(
            CurveTween(curve: Curves.easeIn),
          ),
          weight: 55,
        ),
      ],
    ).animate(_controller);

    _controller.repeat(reverse: true);

    _redirectTimer = Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        context.go(AppRoutes.login);
      },
    );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _iconScale,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: AppColors.p05,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.textInverse,
                    size: 68,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              Text(
                'Cadastro realizado!',
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'Sua conta foi criada com sucesso.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Você será redirecionado para o login.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}