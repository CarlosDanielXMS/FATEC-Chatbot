import 'package:chatbot/features/auth/domain/entities/app_user_profile.dart';
import 'package:chatbot/features/auth/domain/enums/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUserProfile', () {
    test('calcula flags de papel e perfil de paciente', () {
      const profile = AppUserProfile(
        uid: 'uid-1',
        email: 'maria@example.com',
        emailVerified: true,
        role: UserRole.patient,
        name: 'Maria Silva',
        cpf: '52998224725',
      );

      expect(profile.hasRole, isTrue);
      expect(profile.isPatient, isTrue);
      expect(profile.isProfessional, isFalse);
      expect(profile.hasDomainProfile, isTrue);
    });

    test('firstName retorna primeiro nome normalizado ou fallback', () {
      const named = AppUserProfile(
        uid: 'uid-1',
        email: 'maria@example.com',
        emailVerified: false,
        name: '  Maria   Silva  ',
      );
      const unnamed = AppUserProfile(
        uid: 'uid-2',
        email: 'user@example.com',
        emailVerified: false,
      );

      expect(named.firstName, 'Maria');
      expect(unnamed.firstName, 'Usuário');
    });

    test('hasDomainProfile exige nome, CPF e role', () {
      const withoutRole = AppUserProfile(
        uid: 'uid-1',
        email: 'maria@example.com',
        emailVerified: false,
        name: 'Maria Silva',
        cpf: '52998224725',
      );
      const withoutCpf = AppUserProfile(
        uid: 'uid-1',
        email: 'maria@example.com',
        emailVerified: false,
        role: UserRole.patient,
        name: 'Maria Silva',
      );

      expect(withoutRole.hasDomainProfile, isFalse);
      expect(withoutCpf.hasDomainProfile, isFalse);
    });

    test('copyWith preserva campos não informados e substitui informados', () {
      const profile = AppUserProfile(
        uid: 'uid-1',
        email: 'old@example.com',
        emailVerified: false,
        role: UserRole.patient,
        name: 'Maria Silva',
      );

      final copy = profile.copyWith(
        email: 'new@example.com',
        emailVerified: true,
        role: UserRole.professional,
        council: 'CRM 123',
      );

      expect(copy.uid, 'uid-1');
      expect(copy.email, 'new@example.com');
      expect(copy.emailVerified, isTrue);
      expect(copy.role, UserRole.professional);
      expect(copy.name, 'Maria Silva');
      expect(copy.council, 'CRM 123');
    });
  });
}
