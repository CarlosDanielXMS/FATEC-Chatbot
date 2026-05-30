import 'package:chatbot/core/ui/widgets/layout/app_page_padding.dart';
import 'package:chatbot/core/ui/widgets/layout/app_scaffold.dart';
import 'package:chatbot/core/ui/widgets/layout/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Layout widgets', () {
    testWidgets('AppPagePadding exibe child com Padding', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AppPagePadding(child: Text('Conteúdo'))));

      expect(find.byType(Padding), findsWidgets);
      expect(find.text('Conteúdo'), findsOneWidget);
    });

    testWidgets('AppScaffold renderiza body, appBar e bottomNavigationBar', (tester) async {
      await tester.pumpWidget(
        wrapAsPage(
          const AppScaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: Text('Topo'),
            ),
            body: Text('Body'),
            bottomNavigationBar: Text('Bottom'),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('AppSection exibe título, subtítulo e conteúdo', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppSection(
            title: 'Seção',
            subtitle: 'Subtítulo',
            child: Text('Conteúdo'),
          ),
        ),
      );

      expect(find.text('Seção'), findsOneWidget);
      expect(find.text('Subtítulo'), findsOneWidget);
      expect(find.text('Conteúdo'), findsOneWidget);
    });
  });
}
