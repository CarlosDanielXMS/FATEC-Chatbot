import 'package:chatbot/core/config/app_config.dart';
import 'package:chatbot/core/config/legal_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Configurações globais', () {
    test('AppConfig expõe nome do app', () {
      expect(AppConfig.appName, 'BeValue');
    });

    test('LegalConfig expõe versões legais esperadas', () {
      expect(LegalConfig.termsVersion, '2026.03.07');
      expect(LegalConfig.privacyPolicyVersion, '2026.03.07');
    });
  });
}
