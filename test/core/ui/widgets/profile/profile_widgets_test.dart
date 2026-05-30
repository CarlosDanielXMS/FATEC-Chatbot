import 'package:chatbot/core/ui/widgets/profile/preference_switch_tile.dart';
import 'package:chatbot/core/ui/widgets/profile/profile_header_card.dart';
import 'package:chatbot/core/ui/widgets/profile/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Profile widgets', () {
    testWidgets('PreferenceSwitchTile exibe dados e chama onChanged', (tester) async {
      bool? value;

      await tester.pumpWidget(
        wrapWithMaterial(
          PreferenceSwitchTile(
            title: 'Notificações',
            subtitle: 'Receba lembretes',
            value: false,
            onChanged: (next) => value = next,
          ),
        ),
      );
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('Notificações'), findsOneWidget);
      expect(find.text('Receba lembretes'), findsOneWidget);
      expect(value, isTrue);
    });

    testWidgets('ProfileHeaderCard exibe nome/e-mail e botão de edição', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          ProfileHeaderCard(
            name: 'Maria Silva',
            email: 'maria@example.com',
            onEditPressed: () => taps++,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);
      expect(taps, 1);
    });

    testWidgets('SettingsTile exibe textos e executa onTap', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          SettingsTile(
            title: 'Conta',
            subtitle: 'Dados pessoais',
            leading: const Icon(Icons.person),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('Conta'));
      await tester.pump();

      expect(find.text('Conta'), findsOneWidget);
      expect(find.text('Dados pessoais'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(taps, 1);
    });
  });
}
