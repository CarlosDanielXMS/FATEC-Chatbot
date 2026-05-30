import 'package:chatbot/core/persistence/local_storage.dart';

abstract final class OnboardingStorageKeys {
  static const completed = 'onboarding_completed';
}

class OnboardingLocalStore {
  OnboardingLocalStore(this._localStorage);

  final LocalStorage _localStorage;

  bool isCompleted() {
    return _localStorage.readBool(OnboardingStorageKeys.completed) ?? false;
  }

  Future<void> setCompleted() async {
    await _localStorage.writeBool(
      key: OnboardingStorageKeys.completed,
      value: true,
    );
  }
}