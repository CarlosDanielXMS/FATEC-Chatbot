import 'package:chatbot/core/routing/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRoutes', () {
    test('expõe rotas estáticas principais', () {
      expect(AppRoutes.splash, '/splash');
      expect(AppRoutes.onboarding, '/onboarding');
      expect(AppRoutes.authHome, '/auth');
      expect(AppRoutes.login, '/auth/login');
      expect(AppRoutes.register, '/auth/register');
      expect(AppRoutes.patientHome, '/patient');
      expect(AppRoutes.patientMedications, '/patient/medications');
      expect(AppRoutes.professionalHome, '/professional');
    });

    test('monta rotas derivadas corretamente', () {
      expect(AppRoutes.patientSideEffects, '/patient/side-effects');
      expect(AppRoutes.patientAdherenceHistory, '/patient/profile/adherence-history');
      expect(AppRoutes.patientMedicationEdit('med-1'), '/patient/medications/med-1/edit');
    });
  });
}
