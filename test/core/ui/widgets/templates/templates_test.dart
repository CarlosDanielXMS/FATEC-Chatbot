import 'package:chatbot/core/ui/widgets/templates/success_page_template.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Templates', () {
    testWidgets('SuccessPageTemplate exibe feedback de sucesso e ação', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapAsPage(
          SuccessPageTemplate(
            title: 'Cadastro concluído',
            description: 'Sua conta foi criada.',
            actionLabel: 'Continuar',
            onActionPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Continuar'));
      await tester.pump();

      expect(find.text('Cadastro concluído'), findsOneWidget);
      expect(find.text('Sua conta foi criada.'), findsOneWidget);
      expect(taps, 1);
    });
  });
}
