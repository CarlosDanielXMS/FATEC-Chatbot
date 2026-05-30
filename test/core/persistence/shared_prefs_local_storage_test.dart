import 'package:chatbot/core/persistence/shared_prefs_local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPrefsLocalStorage', () {
    test('readBool retorna null quando chave não existe', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPrefsLocalStorage(prefs);

      expect(storage.readBool('missing'), isNull);
    });

    test('writeBool persiste e readBool lê o valor', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SharedPrefsLocalStorage(prefs);

      await storage.writeBool(key: 'flag', value: true);

      expect(storage.readBool('flag'), isTrue);
      expect(prefs.getBool('flag'), isTrue);
    });
  });
}
