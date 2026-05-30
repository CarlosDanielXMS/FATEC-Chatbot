import 'package:chatbot/core/validation/validation_result.dart';

class TermsAcceptanceValidationResult implements ValidationResult {
  const TermsAcceptanceValidationResult({
    required this.hasAcceptedTerms,
  });

  final bool hasAcceptedTerms;

  @override
  bool get isValid {
    return hasAcceptedTerms;
  }

  @override
  String? get errorMessage {
    if (isValid) return null;
    if (!hasAcceptedTerms) return 'Você precisa aceitar os Termos de Uso e Privacidade.';

    return 'Aceite os Termos de Uso e Privacidade.';
  }
}

abstract final class TermsAcceptanceValidator {
  static TermsAcceptanceValidationResult validate(bool accepted) {
    return TermsAcceptanceValidationResult(
      hasAcceptedTerms: accepted,
    );
  }

  static bool isValid(bool accepted) {
    return validate(accepted).isValid;
  }
}