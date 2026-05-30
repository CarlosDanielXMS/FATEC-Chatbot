import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_back_button.dart';
import 'package:chatbot/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordSentPage extends StatefulWidget {
  const ForgotPasswordSentPage({
    super.key,
    required this.authRepository,
    required this.email,
  });

  final AuthRepository authRepository;
  final String email;

  @override
  State<ForgotPasswordSentPage> createState() => _ForgotPasswordSentPageState();
}

class _ForgotPasswordSentPageState extends State<ForgotPasswordSentPage> {
  bool _isResending = false;

  Future<void> _resend() async {
    final email = widget.email.trim();

    if (_isResending || email.isEmpty) return;

    setState(() {
      _isResending = true;
    });

    try {
      await widget.authRepository.sendPasswordResetEmail(email);

      if (!mounted) return;

      _showMessage('E-mail reenviado com sucesso.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(_mapError(error));
    } catch (_) {
      if (!mounted) return;

      _showMessage('Não foi possível reenviar o e-mail.');
    } finally {
      if (mounted){
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  String _mapError(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
        return 'Verifique sua conexão e tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns instantes e tente novamente.';
      default:
        return 'Não foi possível reenviar o e-mail.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _pop() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.forgotPassword);
  }

  void _returnToLogin() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email.trim();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 48,
        leading: AppBackButton(
          onPressed: _pop,
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          'Código enviado',
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s24,
            AppSpacing.s16,
            AppSpacing.s20,
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enviamos as instruções de recuperação para:',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      email.isEmpty ? 'seu e-mail' : email,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    Text(
                      'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton.secondary(
                label: _isResending ? 'Reenviando...' : 'Reenviar e-mail',
                onPressed: _isResending ? null : _resend,
                isLoading: _isResending,
              ),
              const SizedBox(height: AppSpacing.s12),
              AppButton.primary(
                label: 'Voltar para login',
                onPressed: _returnToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}