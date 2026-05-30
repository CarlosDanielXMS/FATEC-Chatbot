abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  static const authHome = '/auth';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const registerSuccess = '/auth/register/success';

  static const forgotPassword = '/auth/forgot-password';
  static const forgotPasswordSent = '/auth/forgot-password/sent';

  static const patientHome = '/patient';
  static const patientSideEffectsSegment = 'side-effects';
  static const patientChatBotSegment = 'chatbot';

  static const patientMedications = '/patient/medications';
  static const patientMedicationAdd = '/patient/medications/add';
  static const patientMedicationAddSegment = 'add';
  static const patientMedicationEditSegment = ':medicationId/edit';

  static const patientAlarms = '/patient/alarms';

  static const patientProfile = '/patient/profile';
  static const patientAdherenceHistorySegment = 'adherence-history';

  static const professionalHome = '/professional';
  static const professionalReports = '/professional/reports';
  static const professionalProfile = '/professional/profile';

  static String get patientSideEffects {
    return '$patientHome/$patientSideEffectsSegment';
  }

  static String get patientChatBot {
    return '$patientHome/$patientChatBotSegment';
  }

  static String get patientAdherenceHistory {
    return '$patientProfile/$patientAdherenceHistorySegment';
  }

  static String patientMedicationEdit(String medicationId) {
    return '$patientMedications/$medicationId/edit';
  }
}