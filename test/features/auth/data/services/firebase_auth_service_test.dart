import 'package:chatbot/features/auth/data/services/firebase_auth_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAuthService - validações client-side', () {
    test('registerPatient rejeita termos não aceitos antes de chamar Auth', () async {
      final service = FirebaseAuthService(
        auth: MockFirebaseAuth(),
        firestore: FakeFirebaseFirestore(),
      );

      await expectLater(
        service.registerPatient(
          name: 'Maria Silva',
          cpf: '52998224725',
          email: 'maria@example.com',
          password: 'Senha@123',
          acceptedTerms: false,
        ),
        throwsA(isA<FirebaseAuthException>().having((error) => error.code, 'code', 'terms-not-accepted')),
      );
    });

    test('registerProfessional rejeita termos não aceitos antes de chamar Auth', () async {
      final service = FirebaseAuthService(
        auth: MockFirebaseAuth(),
        firestore: FakeFirebaseFirestore(),
      );

      await expectLater(
        service.registerProfessional(
          name: 'Maria Silva',
          cpf: '52998224725',
          council: 'CRM 12345',
          email: 'maria@example.com',
          password: 'Senha@123',
          acceptedTerms: false,
        ),
        throwsA(isA<FirebaseAuthException>().having((error) => error.code, 'code', 'terms-not-accepted')),
      );
    });

    test('signIn rejeita CPF client-side e identificador inválido', () async {
      final service = FirebaseAuthService(
        auth: MockFirebaseAuth(),
        firestore: FakeFirebaseFirestore(),
      );

      await expectLater(
        service.signIn(emailOrCpf: '529.982.247-25', password: 'Senha@123'),
        throwsA(isA<FirebaseAuthException>().having((error) => error.code, 'code', 'cpf-login-not-supported-client-side')),
      );
      await expectLater(
        service.signIn(emailOrCpf: 'login inválido', password: 'Senha@123'),
        throwsA(isA<FirebaseAuthException>().having((error) => error.code, 'code', 'invalid-login-identifier')),
      );
    });

    test('sendPasswordResetEmail rejeita e-mail inválido', () async {
      final service = FirebaseAuthService(
        auth: MockFirebaseAuth(),
        firestore: FakeFirebaseFirestore(),
      );

      await expectLater(
        service.sendPasswordResetEmail('invalid'),
        throwsA(isA<FirebaseAuthException>().having((error) => error.code, 'code', 'invalid-email')),
      );
    });
  });
}
