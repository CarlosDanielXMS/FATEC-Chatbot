import 'package:chatbot/core/ui/theme/app_spacing.dart';
import 'package:chatbot/core/ui/widgets/layout/layout.dart';
import 'package:flutter/material.dart';

class ListPageTemplate extends StatelessWidget {
  const ListPageTemplate({
    super.key,
    required this.body,
    this.appBar,
    this.header,
    this.footer,
    this.floatingActionButton,
    this.usePadding = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? header;
  final Widget? footer;
  final Widget? floatingActionButton;
  final bool usePadding;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        if (header != null) ...[
          header!,
          const SizedBox(height: AppSpacing.s16),
        ],
        Expanded(child: body),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.s8),
          footer!,
        ],
      ],
    );

    return AppScaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: usePadding ? AppPagePadding(child: content) : content,
    );
  }
}