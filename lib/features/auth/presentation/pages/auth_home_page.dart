import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatbot/features/auth/presentation/widgets/auth_header_background.dart';
import 'package:chatbot/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthHomePage extends StatefulWidget {
  const AuthHomePage({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  State<AuthHomePage> createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage> {
  bool _isGoogleSubmitting = false;

  Future<void> _signInWithGoogle() async {
    if (_isGoogleSubmitting) return;

    setState(() {
      _isGoogleSubmitting = true;
    });

    try {
      await widget.authRepository.signInWithGoogle();

      if (!mounted) return;

      _completeAuthentication();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      if (_isGoogleCancelation(error)) return;

      _showErrorMessage(_mapGoogleSignInError(error));
    } catch (_) {
      if (!mounted) return;

      _showErrorMessage('Não foi possível entrar com Google.');
    } finally {
      if (mounted){
        setState(() {
          _isGoogleSubmitting = false;
        });
      }
    }
  }

  bool _isGoogleCancelation(FirebaseAuthException error) {
    switch (error.code) {
      case 'google-sign-in-canceled':
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return true;
      default:
        return false;
    }
  }

  String _mapGoogleSignInError(FirebaseAuthException error) {
    switch (error.code) {
      case 'google-sign-in-canceled':
        return 'Login com Google cancelado.';
      case 'google-account-not-registered':
        return 'Cadastre-se antes de entrar com Google.';
      case 'google-profile-not-found':
        return 'Perfil do usuário não encontrado. Entre em contato com o suporte.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este e-mail. Entre com e-mail e senha.';
      default:
        return 'Não foi possível entrar com Google.';
    }
  }

  void _completeAuthentication() {
    context.go(AppRoutes.authHome);
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goToRegister() {
    context.push(AppRoutes.register);
  }

  void _goToLogin() {
    context.push(AppRoutes.login);
  }

  Widget _buildGoogleButton() {
    return AuthSocialButton(
      label: _isGoogleSubmitting ? 'Entrando...' : 'Continue com o Google',
      onPressed: _isGoogleSubmitting ? null : _signInWithGoogle,
      leading: _isGoogleSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.asset(
              'assets/icons/tabler-icon-google.png',
              width: 20,
              height: 20,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AuthHeaderBackground(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s24),
                child: Image.asset(
                  'assets/images/Imagem-Idoso.png',
                  height: 466,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Bem-vindo(a)!',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'Comece agora a cuidar do que importa.\nCadastre-se ou entre na sua conta.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  AppButton.primary(
                    label: 'Cadastro',
                    onPressed: _isGoogleSubmitting ? null : _goToRegister,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isGoogleSubmitting ? null : _goToLogin,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.p05,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: AppTypography.label.copyWith(
                          color: AppColors.p05,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12,
                        ),
                        child: Text(
                          'Ou',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  _buildGoogleButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}