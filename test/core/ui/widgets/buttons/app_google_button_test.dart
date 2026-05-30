import 'package:chatbot/core/ui/widgets/buttons/app_google_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('AppGoogleButton', () {
    testWidgets('exibe label padrão e chama callback', (tester) async {
      var taps = 0;

      await tester.pumpWidget(wrapWithMaterial(AppGoogleButton(onPressed: () => taps++)));
      await tester.pump();
      await tester.tap(find.text('Continue com o Google'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('em loading mostra Entrando e indicador', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AppGoogleButton(onPressed: null, isLoading: true)));

      expect(find.text('Entrando...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
