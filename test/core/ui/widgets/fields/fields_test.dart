import 'package:chatbot/core/ui/widgets/fields/app_checkbox.dart';
import 'package:chatbot/core/ui/widgets/fields/app_field_error_text.dart';
import 'package:chatbot/core/ui/widgets/fields/app_field_hint.dart';
import 'package:chatbot/core/ui/widgets/fields/app_field_label.dart';
import 'package:chatbot/core/ui/widgets/fields/app_switch_tile.dart';
import 'package:chatbot/core/ui/widgets/fields/app_text_field.dart';
import 'package:chatbot/core/ui/widgets/fields/app_verification_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Fields', () {
    testWidgets('AppCheckbox exibe label e envia valor invertido ao tocar', (tester) async {
      bool? nextValue;

      await tester.pumpWidget(
        wrapWithMaterial(
          AppCheckbox(
            value: false,
            label: 'Aceito os termos',
            onChanged: (value) => nextValue = value,
          ),
        ),
      );
      await tester.tap(find.text('Aceito os termos'));
      await tester.pump();

      expect(find.text('Aceito os termos'), findsOneWidget);
      expect(nextValue, isTrue);
    });

    testWidgets('AppCheckbox não chama callback quando onChanged é null', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppCheckbox(value: false, label: 'Aceito os termos', onChanged: null),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNull);
    });

    testWidgets('AppFieldLabel exibe asterisco quando required', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AppFieldLabel(label: 'Nome', required: true)));

      expect(find.textContaining('Nome'), findsOneWidget);
    });

    testWidgets('AppFieldErrorText e AppFieldHint exibem mensagens', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const Column(children: [
        AppFieldErrorText('Campo obrigatório.'),
        AppFieldHint('Digite seu nome completo.'),
      ])));

      expect(find.text('Campo obrigatório.'), findsOneWidget);
      expect(find.text('Digite seu nome completo.'), findsOneWidget);
    });

    testWidgets('AppSwitchTile exibe título/subtítulo e chama onChanged', (tester) async {
      bool? nextValue;

      await tester.pumpWidget(
        wrapWithMaterial(
          AppSwitchTile(
            value: false,
            title: 'Notificações',
            subtitle: 'Receber lembretes',
            onChanged: (value) => nextValue = value,
          ),
        ),
      );
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('Notificações'), findsOneWidget);
      expect(find.text('Receber lembretes'), findsOneWidget);
      expect(nextValue, isTrue);
    });

    testWidgets('AppTextField exibe label, helper e dispara onChanged', (tester) async {
      String? value;

      await tester.pumpWidget(
        wrapWithMaterial(
          AppTextField(
            label: 'Nome',
            helperText: 'Nome completo',
            onChanged: (text) => value = text,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Maria');
      await tester.pump();

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Nome completo'), findsOneWidget);
      expect(value, 'Maria');
    });

    testWidgets('AppTextField exibe erro no lugar de helper', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppTextField(
            label: 'E-mail',
            helperText: 'Digite seu e-mail',
            errorText: 'Informe um e-mail válido.',
          ),
        ),
      );

      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
      expect(find.text('Digite seu e-mail'), findsNothing);
    });

    testWidgets('AppTextField alterna visibilidade de senha', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppTextField(label: 'Senha', obscureText: true),
        ),
      );

      var field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isFalse);
    });

    testWidgets('AppVerificationCodeField limita tamanho e dispara onChanged', (tester) async {
      final controller = TextEditingController();
      String? value;

      await tester.pumpWidget(
        wrapWithMaterial(
          AppVerificationCodeField(
            controller: controller,
            length: 5,
            onChanged: (text) => value = text,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '12345');
      await tester.pump();

      expect(controller.text, '12345');
      expect(value, '12345');
      expect(find.text('00000'), findsOneWidget);
    });
  });
}
