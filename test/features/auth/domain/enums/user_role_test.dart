import 'package:chatbot/features/auth/domain/enums/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole', () {
    test('expõe value, label e flags do paciente', () {
      expect(UserRole.patient.value, 'patient');
      expect(UserRole.patient.label, 'Paciente');
      expect(UserRole.patient.isPatient, isTrue);
      expect(UserRole.patient.isProfessional, isFalse);
    });

    test('expõe value, label e flags do profissional', () {
      expect(UserRole.professional.value, 'professional');
      expect(UserRole.professional.label, 'Profissional');
      expect(UserRole.professional.isProfessional, isTrue);
      expect(UserRole.professional.isPatient, isFalse);
    });

    test('tryFromString converte texto válido e remove espaços', () {
      expect(UserRole.tryFromString('patient'), UserRole.patient);
      expect(UserRole.tryFromString(' professional '), UserRole.professional);
    });

    test('tryFromString retorna null para valores inválidos', () {
      expect(UserRole.tryFromString(null), isNull);
      expect(UserRole.tryFromString('admin'), isNull);
      expect(UserRole.tryFromString(''), isNull);
    });

    test('fromString lança ArgumentError para valores inválidos', () {
      expect(() => UserRole.fromString('admin'), throwsArgumentError);
    });
  });
}
