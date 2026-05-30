abstract interface class ValidationResult {
  bool get isValid;
  String? get errorMessage;
}