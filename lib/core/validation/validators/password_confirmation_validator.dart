import 'package:chatbot/core/validation/validation_result.dart';

class PasswordConfirmationValidationResult implements ValidationResult {
  const PasswordConfirmationValidationResult({
    required this.hasPassword,
    required this.hasConfirmation,
    required this.hasEqualValues,
  });

  final bool hasPassword;
  final bool hasConfirmation;
  final bool hasEqualValues;

  @override
  bool get isValid {
    return hasPassword && hasConfirmation && hasEqualValues;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasPassword) return 'Informe a senha.';
    if (!hasConfirmation) return 'Confirme a senha.';
    if (!hasEqualValues) return 'As senhas não coincidem.';
    
    return 'Confirme a senha.';
  }
}

abstract final class PasswordConfirmationValidator {
  static PasswordConfirmationValidationResult validate({
    required String password,
    required String confirmation,
  }) {
    return PasswordConfirmationValidationResult(
      hasPassword: password.isNotEmpty,
      hasConfirmation: confirmation.isNotEmpty,
      hasEqualValues: password.isNotEmpty &&
          confirmation.isNotEmpty &&
          password == confirmation,
    );
  }

  static bool isValid({
    required String password,
    required String confirmation,
  }) {
    return validate(
      password: password,
      confirmation: confirmation,
    ).isValid;
  }
}