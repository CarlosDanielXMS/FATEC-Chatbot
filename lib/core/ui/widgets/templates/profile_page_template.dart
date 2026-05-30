import 'package:chatbot/core/ui/theme/app_spacing.dart';
import 'package:chatbot/core/ui/widgets/layout/layout.dart';
import 'package:flutter/material.dart';

class ProfilePageTemplate extends StatelessWidget {
  const ProfilePageTemplate({
    super.key,
    required this.header,
    required this.sections,
    this.appBar,
  });

  final Widget header;
  final List<Widget> sections;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: AppPagePadding(
          child: Column(
            children: [
              header,
              const SizedBox(height: AppSpacing.s24),
              ..._withSpacing(sections),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    final result = <Widget>[];

    for (var index = 0; index < items.length; index++) {
      result.add(items[index]);

      if (index < items.length - 1) {
        result.add(const SizedBox(height: AppSpacing.s16));
      }
    }

    return result;
  }
}