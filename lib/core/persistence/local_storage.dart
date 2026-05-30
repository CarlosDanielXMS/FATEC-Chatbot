abstract interface class LocalStorage {
  Future<void> writeBool({
    required String key,
    required bool value,
  });

  bool? readBool(String key);
}