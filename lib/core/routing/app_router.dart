import 'package:chatbot/features/auth/data/repositories/firebase_auth_repository_impl.dart';
import 'package:chatbot/features/auth/presentation/pages/auth_home_page.dart';
import 'package:chatbot/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:chatbot/features/auth/presentation/pages/forgot_password_sent_page.dart';
import 'package:chatbot/features/auth/presentation/pages/login_page.dart';
import 'package:chatbot/features/auth/presentation/pages/register_page.dart';
import 'package:chatbot/features/auth/presentation/pages/register_success_page.dart';
import 'package:chatbot/features/chatbot/presentation/pages/main.dart';
import 'package:chatbot/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:chatbot/features/patient/data/repositories/firestore_adherence_event_repository_impl.dart';
import 'package:chatbot/features/patient/data/repositories/firestore_alarm_repository_impl.dart';
import 'package:chatbot/features/patient/data/repositories/firestore_medication_repository_impl.dart';
import 'package:chatbot/features/patient/presentation/pages/medication_form_page.dart';
import 'package:chatbot/features/patient/presentation/pages/patient_adherence_history_page.dart';
import 'package:chatbot/features/patient/presentation/pages/patient_alarms_page.dart';
import 'package:chatbot/features/patient/presentation/pages/patient_home_page.dart';
import 'package:chatbot/features/patient/presentation/pages/patient_medications_page.dart';
import 'package:chatbot/features/patient/presentation/pages/patient_profile_page.dart';
import 'package:chatbot/features/patient/presentation/pages/patient_shell_page.dart';
import 'package:chatbot/features/patient/presentation/widgets/patient_side_effects_placeholder_page.dart';
import 'package:chatbot/features/professional/presentation/pages/professional_home_page.dart';
import 'package:chatbot/features/professional/presentation/pages/professional_profile_page.dart';
import 'package:chatbot/features/professional/presentation/pages/professional_reports_page.dart';
import 'package:chatbot/features/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation/app_navigation_state.dart';
import 'app_redirector.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static GoRouter createRouter(AppNavigationState navigationState) {
    final redirector = AppRedirector(navigationState);

    final authRepository = FirebaseAuthRepositoryImpl();
    final medicationRepository = FirestoreMedicationRepositoryImpl();
    final alarmRepository = FirestoreAlarmRepositoryImpl();
    final adherenceEventRepository = FirestoreAdherenceEventRepositoryImpl();

    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: navigationState,
      redirect: redirector.redirect,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, _) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, _) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.authHome,
          builder: (_, _) => AuthHomePage(
            authRepository: authRepository,
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => LoginPage(
            authRepository: authRepository,
          ),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, _) => RegisterPage(
            authRepository: authRepository,
          ),
        ),
        GoRoute(
          path: AppRoutes.registerSuccess,
          builder: (_, _) => const RegisterSuccessPage(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, _) => ForgotPasswordPage(
            authRepository: authRepository,
          ),
        ),
        GoRoute(
          path: AppRoutes.forgotPasswordSent,
          builder: (_, state) {
            final email = state.uri.queryParameters['email'] ?? '';

            return ForgotPasswordSentPage(
              authRepository: authRepository,
              email: email,
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) {
            return PatientShellPage(
              navigationShell: navigationShell,
              alarmRepository: alarmRepository,
              adherenceEventRepository: adherenceEventRepository,
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.patientHome,
                  builder: (_, _) => PatientHomePage(
                    authRepository: authRepository,
                    alarmRepository: alarmRepository,
                    medicationRepository: medicationRepository,
                  ),
                  routes: [
                    GoRoute(
                      path: AppRoutes.patientSideEffectsSegment,
                      builder: (_, _) {
                        return const PatientSideEffectsPlaceholderPage();
                      },
                    ),
                    GoRoute(
                      path: AppRoutes.patientChatBotSegment,
                      builder: (_, _) {
                        return const ChatScreen();
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.patientMedications,
                  builder: (_, _) => PatientMedicationsPage(
                    medicationRepository: medicationRepository,
                  ),
                  routes: [
                    GoRoute(
                      path: AppRoutes.patientMedicationAddSegment,
                      builder: (_, _) => MedicationFormPage(
                        medicationRepository: medicationRepository,
                      ),
                    ),
                    GoRoute(
                      path: AppRoutes.patientMedicationEditSegment,
                      builder: (_, state) {
                        final medicationId =
                            state.pathParameters['medicationId'];

                        return MedicationFormPage(
                          medicationId: medicationId,
                          medicationRepository: medicationRepository,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.patientAlarms,
                  builder: (_, _) => PatientAlarmsPage(
                    alarmRepository: alarmRepository,
                    adherenceEventRepository: adherenceEventRepository,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.patientProfile,
                  builder: (_, _) => PatientProfilePage(
                    authRepository: authRepository,
                  ),
                  routes: [
                    GoRoute(
                      path: AppRoutes.patientAdherenceHistorySegment,
                      builder: (_, _) => PatientAdherenceHistoryPage(
                        adherenceEventRepository: adherenceEventRepository,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.professionalHome,
          builder: (_, _) => const ProfessionalHomePage(),
        ),
        GoRoute(
          path: AppRoutes.professionalReports,
          builder: (_, _) => const ProfessionalReportsPage(),
        ),
        GoRoute(
          path: AppRoutes.professionalProfile,
          builder: (_, _) => const ProfessionalProfilePage(),
        ),
      ],
    );
  }
}