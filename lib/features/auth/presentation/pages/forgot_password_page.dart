import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/core/ui/widgets/fields/app_text_field.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_back_button.dart';
import 'package:chatbot/core/validation/validation.dart';
import 'package:chatbot/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  bool _submitted = false;
  bool _isSubmitting = false;
  String? _errorText;

  bool get _hasEmail => _emailController.text.trim().isNotEmpty;

  bool get _canSubmit {
    return !_isSubmitting && _hasEmail;
  }

  String? get _emailError {
    if (_errorText != null) return _errorText;
    if (!_submitted && !_hasEmail) return null;

    return EmailValidator.validate(_emailController.text).errorMessage;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String _) {
    setState(() {
      _errorText = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _errorText = null;
    });

    final validation = EmailValidator.validate(_emailController.text);
    if (!validation.isValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final email = _emailController.text.trim();

    try {
      await widget.authRepository.sendPasswordResetEmail(email);

      if (!mounted) return;

      _goToPasswordResetSent(email);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorText = _mapError(error);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorText = 'Não foi possível enviar o e-mail. Tente novamente.';
      });
    } finally {
      if (mounted){
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _mapError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail.';
      case 'network-request-failed':
        return 'Verifique sua conexão e tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns instantes e tente novamente.';
      default:
        return 'Não foi possível enviar o e-mail. Tente novamente.';
    }
  }

  void _pop() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.login);
  }

  void _goToPasswordResetSent(String email) {
    context.push(
      '${AppRoutes.forgotPasswordSent}?email=${Uri.encodeComponent(email)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 48,
        leading: AppBackButton(
          onPressed: _pop,
        ),
        titleSpacing: 0,
        title: Text(
          'Esqueci minha senha',
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
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informe seu e-mail para receber as instruções de recuperação da senha.',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),
                      AppTextField(
                        label: 'E-mail',
                        controller: _emailController,
                        hintText: 'exemplo@gmail.com',
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onChanged: _onEmailChanged,
                        onSubmitted: (_) => _submit(),
                      ),
                    ],
                  ),
                ),
              ),
              AppButton.primary(
                label: _isSubmitting ? 'Enviando...' : 'Enviar código',
                onPressed: _canSubmit ? _submit : null,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}