import 'dart:async';

import 'package:chatbot/app/app.dart';
import 'package:chatbot/app/app_initializer.dart';
import 'package:flutter/material.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(
    () async {
      const initializer = AppInitializer();
      await initializer.initialize();

      runApp(const App());
    },
    (error, stackTrace) {
      debugPrint(error.toString());
    },
  );
}
