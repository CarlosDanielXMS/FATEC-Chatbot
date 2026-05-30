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

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _invalidCredentialsMessage = 'Usuário ou Senha incorretos';

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _submitted = false;
  bool _hasInvalidCredentials = false;

  bool get _hasIdentifier => _identifierController.text.trim().isNotEmpty;
  bool get _hasPassword => _passwordController.text.isNotEmpty;

  bool get _canSubmit {
    return !_isSubmitting && _hasIdentifier && _hasPassword;
  }

  String? get _identifierError {
    if (_hasInvalidCredentials) return _invalidCredentialsMessage;
    if (!_submitted || !_hasIdentifier) return null;

    final validation = LoginIdentifierValidator.validate(
      _identifierController.text,
    );

    return validation.errorMessage;
  }

  String? get _passwordError {
    if (_hasInvalidCredentials) return _invalidCredentialsMessage;
    if (!_submitted || _hasPassword) return null;

    return 'Informe a senha.';
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFieldChanged(String _) {
    setState(() {
      _hasInvalidCredentials = false;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _hasInvalidCredentials = false;
    });

    if (!_canSubmit) return;

    final identifierValidation = LoginIdentifierValidator.validate(
      _identifierController.text,
    );

    if (!identifierValidation.isValid) {
      setState(() {});
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.authRepository.signIn(
        emailOrCpf: _identifierController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      _completeAuthentication();
    } on FirebaseAuthException {
      if (!mounted) return;

      setState(() {
        _hasInvalidCredentials = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasInvalidCredentials = true;
      });
    } finally {
      if (mounted){
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _completeAuthentication() {
    context.go(AppRoutes.authHome);
  }

  void _pop() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.authHome);
  }

  void _goToForgotPassword() {
    context.push(AppRoutes.forgotPassword);
  }

  void _goToRegister() {
    context.push(AppRoutes.register);
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/logos/ilustracao.png',
          height: 58,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          'Seu tratamento, nossa prioridade.\nSempre com você',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Email / CPF',
          controller: _identifierController,
          hintText: 'Digite o seu Email/CPF aqui',
          errorText: _identifierError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: _onFieldChanged,
        ),
        const SizedBox(height: AppSpacing.s20),
        AppTextField(
          label: 'Senha',
          controller: _passwordController,
          hintText: '********',
          errorText: _passwordError,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: _onFieldChanged,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.s8),
        GestureDetector(
          onTap: _goToForgotPassword,
          child: Text(
            'Esqueceu a senha?',
            style: AppTypography.caption.copyWith(
              color: AppColors.s03,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.s16,
        right: AppSpacing.s16,
        bottom: AppSpacing.s20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton.primary(
            label: _isSubmitting ? 'Entrando...' : 'Avançar',
            onPressed: _canSubmit ? _submit : null,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: AppSpacing.s20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Não tem uma conta? ',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: _goToRegister,
                child: Text(
                  'Faça seu cadastro',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.s03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          'Login',
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s24,
                  AppSpacing.s16,
                  AppSpacing.s16,
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.s32),
                    _buildForm(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}