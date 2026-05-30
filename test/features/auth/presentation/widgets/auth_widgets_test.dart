import 'package:chatbot/features/auth/domain/enums/user_role.dart';
import 'package:chatbot/features/auth/presentation/widgets/password_rules_checklist.dart';
import 'package:chatbot/features/auth/presentation/widgets/register_step_indicator.dart';
import 'package:chatbot/features/auth/presentation/widgets/register_user_type_switch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Auth widgets', () {
    testWidgets('PasswordRulesChecklist exibe regras de senha', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const PasswordRulesChecklist(password: 'Senha@123')));
      await tester.pump();

      expect(find.text('A senha deve ter:'), findsOneWidget);
      expect(find.text('Mínimo de 1 letra maiúscula'), findsOneWidget);
      expect(find.text('Mínimo de 1 letra minúscula'), findsOneWidget);
      expect(find.text('Mínimo de 1 caractere especial'), findsOneWidget);
      expect(find.text('Mínimo de 1 número'), findsOneWidget);
      expect(find.text('Mínimo de 8 caracteres'), findsOneWidget);
    });

    testWidgets('RegisterUserTypeSwitch alterna tipo selecionado', (tester) async {
      RegisterUserType? selected;

      await tester.pumpWidget(
        wrapWithMaterial(
          RegisterUserTypeSwitch(
            selectedType: RegisterUserType.patient,
            onChanged: (type) => selected = type,
          ),
        ),
      );
      await tester.tap(find.text(UserRole.professional.label));
      await tester.pump();

      expect(find.text('Paciente'), findsOneWidget);
      expect(find.text('Profissional'), findsOneWidget);
      expect(selected, RegisterUserType.professional);
    });

    testWidgets('RegisterStepIndicator exibe etapa atual', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const RegisterStepIndicator(currentStep: 2, totalSteps: 3)));

      expect(find.text('Passo 2 de 3'), findsOneWidget);
    });
  });
}
