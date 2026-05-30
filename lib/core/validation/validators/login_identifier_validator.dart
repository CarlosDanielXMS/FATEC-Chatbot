import 'package:chatbot/core/validation/validation_result.dart';

import 'cpf_validator.dart';
import 'email_validator.dart';

class LoginIdentifierValidationResult implements ValidationResult {
  const LoginIdentifierValidationResult({
    required this.hasValue,
    required this.hasValidEmail,
    required this.hasValidCpf,
  });

  final bool hasValue;
  final bool hasValidEmail;
  final bool hasValidCpf;

  @override
  bool get isValid {
    return hasValue && (hasValidEmail || hasValidCpf);
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasValue) return 'Informe o e-mail ou CPF.';

    return 'Informe um e-mail ou CPF válido.';
  }
}

abstract final class LoginIdentifierValidator {
  static LoginIdentifierValidationResult validate(String value) {
    final normalized = value.trim();

    return LoginIdentifierValidationResult(
      hasValue: normalized.isNotEmpty,
      hasValidEmail: EmailValidator.isValid(normalized),
      hasValidCpf: CpfValidator.isValid(normalized),
    );
  }

  static bool isValid(String value) {
    return validate(value).isValid;
  }
}