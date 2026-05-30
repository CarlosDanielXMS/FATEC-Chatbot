import 'package:chatbot/core/config/legal_config.dart';
import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/auth/data/services/auth_legal_acceptance_service.dart';
import 'package:chatbot/features/auth/domain/entities/app_user_profile.dart';
import 'package:chatbot/features/auth/domain/enums/user_role.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthLegalAcceptanceService', () {
    test('registra aceite legal com versões configuradas', () async {
      final firestore = FakeFirebaseFirestore();
      final service = AuthLegalAcceptanceService(firestore: firestore);
      const profile = AppUserProfile(
        uid: 'uid-1',
        email: 'maria@example.com',
        emailVerified: true,
        role: UserRole.patient,
      );

      await service.registerAcceptance(profile);

      final snapshot = await firestore.collection(FirestoreCollections.legalAcceptances).get();
      expect(snapshot.docs, hasLength(1));

      final data = snapshot.docs.single.data();
      expect(data[FirestoreFields.uid], 'uid-1');
      expect(data[FirestoreFields.email], 'maria@example.com');
      expect(data[FirestoreFields.role], 'patient');
      expect(data[FirestoreFields.termsAccepted], isTrue);
      expect(data[FirestoreFields.termsVersion], LegalConfig.termsVersion);
      expect(data[FirestoreFields.privacyPolicyVersion], LegalConfig.privacyPolicyVersion);
    });

    test('lança StateError quando profile não possui role', () async {
      final service = AuthLegalAcceptanceService(firestore: FakeFirebaseFirestore());
      const profile = AppUserProfile(
        uid: 'uid-1',
        email: 'maria@example.com',
        emailVerified: true,
      );

      await expectLater(service.registerAcceptance(profile), throwsStateError);
    });
  });
}
