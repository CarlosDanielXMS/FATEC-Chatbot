import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/core/ui/widgets/fields/app_text_field.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_back_button.dart';
import 'package:chatbot/core/validation/validation.dart';
import 'package:chatbot/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatbot/features/auth/presentation/widgets/password_rules_checklist.dart';
import 'package:chatbot/features/auth/presentation/widgets/register_step_indicator.dart';
import 'package:chatbot/features/auth/presentation/widgets/register_user_type_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterUserType _selectedType = RegisterUserType.patient;
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _councilController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isSubmitting = false;
  bool _termsTouched = false;

  String? _submitError;

  bool get _isProfessional => _selectedType == RegisterUserType.professional;
  bool get _isStepOne => _currentStep == 0;
  bool get _isStepTwo => _currentStep == 1;

  FullNameValidationResult get _nameValidation {
    return FullNameValidator.validate(_nameController.text);
  }

  CpfValidationResult get _cpfValidation {
    return CpfValidator.validate(_cpfController.text);
  }

  CouncilValidationResult get _councilValidation {
    return CouncilValidator.validate(_councilController.text);
  }

  EmailValidationResult get _emailValidation {
    return EmailValidator.validate(_emailController.text);
  }

  PasswordValidationResult get _passwordValidation {
    return PasswordValidator.validate(_passwordController.text);
  }

  PasswordConfirmationValidationResult get _passwordConfirmationValidation {
    return PasswordConfirmationValidator.validate(
      password: _passwordController.text,
      confirmation: _confirmPasswordController.text,
    );
  }

  TermsAcceptanceValidationResult get _termsValidation {
    return TermsAcceptanceValidator.validate(_acceptedTerms);
  }

  bool get _isStepOneValid {
    final baseIsValid = _nameValidation.isValid && _cpfValidation.isValid;

    if (!_isProfessional) return baseIsValid;

    return baseIsValid && _councilValidation.isValid;
  }

  bool get _isStepTwoValid {
    return _emailValidation.isValid &&
        _passwordValidation.isValid &&
        _passwordConfirmationValidation.isValid &&
        _termsValidation.isValid;
  }

  bool get _canContinue {
    if (_isSubmitting) return false;
    return _isStepOne ? _isStepOneValid : _isStepTwoValid;
  }

  String? get _nameError {
    if (_nameController.text.isEmpty) return null;
    return _nameValidation.errorMessage;
  }

  String? get _cpfError {
    if (_cpfController.text.isEmpty) return null;
    return _cpfValidation.errorMessage;
  }

  String? get _councilError {
    if (_councilController.text.isEmpty) return null;
    return _councilValidation.errorMessage;
  }

  String? get _emailError {
    if (_emailController.text.isEmpty) return null;
    return _emailValidation.errorMessage;
  }

  String? get _passwordError {
    if (_passwordController.text.isEmpty) return null;
    return _passwordValidation.errorMessage;
  }

  String? get _confirmPasswordError {
    if (_confirmPasswordController.text.isEmpty) return null;
    return _passwordConfirmationValidation.errorMessage;
  }

  String? get _termsError {
    if (!_termsTouched) return null;
    return _termsValidation.errorMessage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _councilController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  String _mapRegisterError(FirebaseAuthException error) {
    switch (error.code) {
      case 'terms-not-accepted':
        return 'Você precisa aceitar os Termos de Uso e Privacidade.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'weak-password':
        return 'A senha informada é muito fraca.';
      case 'network-request-failed':
        return 'Verifique sua conexão e tente novamente.';
      default:
        return 'Não foi possível concluir o cadastro.';
    }
  }

  void _onChangeUserType(RegisterUserType type) {
    if (_selectedType == type) return;

    setState(() {
      _selectedType = type;
      _currentStep = 0;
      _acceptedTerms = false;
      _termsTouched = false;
      _isSubmitting = false;
      _submitError = null;

      _nameController.clear();
      _cpfController.clear();
      _councilController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _handleContinue() async {
    if (!_canContinue || _isSubmitting) return;

    if (_isStepOne) {
      setState(() {
        _currentStep = 1;
        _submitError = null;
      });
      return;
    }

    await _submitRegister();
  }

  Future<void> _submitRegister() async {
    setState(() {
      _isSubmitting = true;
      _submitError = null;
      _termsTouched = true;
    });

    try {
      if (_isProfessional) {
        await widget.authRepository.registerProfessional(
          name: FullNameValidator.normalize(_nameController.text),
          cpf: CpfValidator.normalize(_cpfController.text),
          council: CouncilValidator.normalize(_councilController.text),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          acceptedTerms: _acceptedTerms,
        );
      } else {
        await widget.authRepository.registerPatient(
          name: FullNameValidator.normalize(_nameController.text),
          cpf: CpfValidator.normalize(_cpfController.text),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          acceptedTerms: _acceptedTerms,
        );
      }

      if (!mounted) return;
      context.go(AppRoutes.registerSuccess);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _submitError = _mapRegisterError(error);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _submitError = 'Não foi possível concluir o cadastro.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleBackPressed() {
    if (_isStepTwo) {
      setState(() {
        _currentStep = 0;
        _submitError = null;
      });
      return;
    }

    context.go(AppRoutes.authHome);
  }

  Widget _buildHeader() {
    return Column(
      children: [
        RegisterUserTypeSwitch(
          selectedType: _selectedType,
          onChanged: _onChangeUserType,
        ),
        const SizedBox(height: AppSpacing.s20),
        Image.asset(
          'assets/logos/ilustracao.png',
          height: 64,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          'Criar Conta',
          style: AppTypography.h1.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s8),
        RegisterStepIndicator(
          currentStep: _currentStep + 1,
          totalSteps: 2,
        ),
      ],
    );
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Nome Completo',
          controller: _nameController,
          hintText: 'Digite o seu nome aqui',
          errorText: _nameError,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _refresh(),
        ),
        const SizedBox(height: AppSpacing.s16),
        AppTextField(
          label: 'CPF',
          controller: _cpfController,
          hintText: 'XXX.XXX.XXX-XX',
          errorText: _cpfError,
          keyboardType: TextInputType.number,
          textInputAction:
              _isProfessional ? TextInputAction.next : TextInputAction.done,
          onChanged: (_) => _refresh(),
        ),
        if (_isProfessional) ...[
          const SizedBox(height: AppSpacing.s16),
          AppTextField(
            label: 'Conselho',
            controller: _councilController,
            hintText: 'XXX.XX',
            errorText: _councilError,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _refresh(),
          ),
        ],
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'E-mail',
          controller: _emailController,
          hintText: 'exemplo@gmail.com',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _refresh(),
        ),
        const SizedBox(height: AppSpacing.s16),
        AppTextField(
          label: 'Senha',
          controller: _passwordController,
          hintText: '********',
          errorText: _passwordError,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _refresh(),
        ),
        const SizedBox(height: AppSpacing.s16),
        AppTextField(
          label: 'Confirmar senha',
          controller: _confirmPasswordController,
          hintText: '********',
          errorText: _confirmPasswordError,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => _refresh(),
        ),
        const SizedBox(height: AppSpacing.s20),
        PasswordRulesChecklist(
          validationResult: _passwordValidation,
        ),
        const SizedBox(height: AppSpacing.s16),
        _buildTermsCheckbox(),
        if (_termsError != null) ...[
          const SizedBox(height: AppSpacing.s4),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s48),
            child: Text(
              _termsError!,
              style: AppTypography.caption.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(0, -2),
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value ?? false;
                _termsTouched = true;
              });
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 13),
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                children: [
                  const TextSpan(text: 'Li e concordo com os '),
                  TextSpan(
                    text: 'Termos de Uso',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.s03,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' e '),
                  TextSpan(
                    text: 'Privacidade.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.s03,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomArea() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.s20,
        top: AppSpacing.s12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton.primary(
            label: _isSubmitting
                ? 'Enviando...'
                : (_isStepOne ? 'Avançar' : 'Cadastrar'),
            onPressed: _canContinue ? _handleContinue : null,
            isLoading: _isSubmitting,
          ),
          if (_submitError != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Text(
              _submitError!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Já tem uma conta? ',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.login),
                child: Text(
                  'Entrar',
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
        leading: AppBackButton(
          onPressed: _handleBackPressed,
        ),
        backgroundColor: AppColors.background,
        title: Text(
          'Cadastre - se',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.s8),
              _buildHeader(),
              const SizedBox(height: AppSpacing.s24),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: AnimatedSwitcher(
                    duration: AppDurations.normal,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: KeyedSubtree(
                      key: ValueKey('${_selectedType.name}_$_currentStep'),
                      child: _isStepOne ? _buildStepOne() : _buildStepTwo(),
                    ),
                  ),
                ),
              ),
              _buildBottomArea(),
            ],
          ),
        ),
      ),
    );
  }
}