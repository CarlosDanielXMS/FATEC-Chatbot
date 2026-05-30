import 'package:chatbot/core/config/legal_config.dart';
import 'package:chatbot/core/firebase/firestore_collections.dart';
import 'package:chatbot/core/firebase/firestore_fields.dart';
import 'package:chatbot/features/auth/domain/entities/app_user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthLegalAcceptanceService {
  AuthLegalAcceptanceService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> registerAcceptance(AppUserProfile profile) async {
    final role = profile.role;

    if (role == null) {
      throw StateError(
        'Não é possível registrar aceite legal sem papel definido.',
      );
    }

    await _firestore.collection(FirestoreCollections.legalAcceptances).add({
      FirestoreFields.uid: profile.uid,
      FirestoreFields.email: profile.email,
      FirestoreFields.role: role.value,
      FirestoreFields.termsAccepted: true,
      FirestoreFields.termsVersion: LegalConfig.termsVersion,
      FirestoreFields.privacyPolicyVersion: LegalConfig.privacyPolicyVersion,
      FirestoreFields.acceptedAt: FieldValue.serverTimestamp(),
    });
  }
}