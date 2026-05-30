import 'package:chatbot/app/navigation/app_navigation_state.dart';
import 'package:chatbot/core/persistence/shared_prefs_local_storage.dart';
import 'package:chatbot/core/routing/app_router.dart';
import 'package:chatbot/features/onboarding/data/onboarding_local_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const firebaseConfig = FirebaseOptions (
  apiKey: "AIzaSyDVL1XpTHBjqWE2L_hs_cEdaU0joqplnLY",
  authDomain: "bevalue-back.firebaseapp.com",
  projectId: "bevalue-back",
  storageBucket: "bevalue-back.firebasestorage.app",
  messagingSenderId: "508565196560",
  appId: "1:508565196560:web:60f2a891643597fe9b5f95",
  measurementId: "G-8FVK8DDW7H"
);

class AppInitializer {
  const AppInitializer();

  static late final SharedPrefsLocalStorage localStorage;
  static late final AppNavigationState navigationState;
  static late final GoRouter router;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    localStorage = SharedPrefsLocalStorage(prefs);

    await Firebase.initializeApp(
      options: firebaseConfig,
    );

    navigationState = AppNavigationState(
      onboardingLocalStore: OnboardingLocalStore(localStorage),
    );

    router = AppRouter.createRouter(navigationState);
  }
}