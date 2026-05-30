import 'package:chatbot/core/persistence/local_storage.dart';
import 'package:chatbot/features/onboarding/data/onboarding_local_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocalStorage implements LocalStorage {
  final values = <String, bool>{};

  @override
  bool? readBool(String key) => values[key];

  @override
  Future<void> writeBool({required String key, required bool value}) async {
    values[key] = value;
  }
}

void main() {
  group('OnboardingLocalStore', () {
    test('isCompleted retorna false quando não existe valor salvo', () {
      final storage = _FakeLocalStorage();
      final store = OnboardingLocalStore(storage);

      expect(store.isCompleted(), isFalse);
    });

    test('isCompleted retorna valor salvo', () {
      final storage = _FakeLocalStorage()
        ..values[OnboardingStorageKeys.completed] = true;
      final store = OnboardingLocalStore(storage);

      expect(store.isCompleted(), isTrue);
    });

    test('setCompleted salva true na chave correta', () async {
      final storage = _FakeLocalStorage();
      final store = OnboardingLocalStore(storage);

      await store.setCompleted();

      expect(storage.values[OnboardingStorageKeys.completed], isTrue);
      expect(store.isCompleted(), isTrue);
    });
  });
}
