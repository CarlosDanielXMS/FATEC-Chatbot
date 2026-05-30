import 'package:chatbot/core/ui/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_progress_dots.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_step_indicator.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Navigation widgets', () {
    testWidgets('AppProgressDots cria quantidade correta de indicadores', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AppProgressDots(total: 3, currentIndex: 1)));

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('AppStepIndicator exibe progresso textual', (tester) async {
      await tester.pumpWidget(wrapWithMaterial(const AppStepIndicator(currentStep: 2, totalSteps: 4)));

      expect(find.text('Etapa 2 de 4'), findsOneWidget);
    });

    testWidgets('AppTopBar exibe título e actions', (tester) async {
      await tester.pumpWidget(
        wrapAsPage(
          const Scaffold(
            appBar: AppTopBar(
              title: 'Perfil',
              actions: [Icon(Icons.settings)],
            ),
          ),
        ),
      );

      expect(find.text('Perfil'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('AppBottomNavigationBar chama onTap em item não selecionado', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        wrapAsPage(
          Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
              items: const [
                AppBottomNavigationItem(iconAsset: 'assets/home.png', label: 'Home'),
                AppBottomNavigationItem(iconAsset: 'assets/profile.png', label: 'Perfil'),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Perfil'));
      await tester.pump();

      expect(tappedIndex, 1);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });
  });
}
