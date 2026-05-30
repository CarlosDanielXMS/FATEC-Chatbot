import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/layout/app_page_padding.dart';
import 'package:chatbot/core/ui/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';

class AuthTemplate extends StatelessWidget {
  const AuthTemplate({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.footer,
    this.header,
    this.appBar,
    this.resizeToAvoidBottomInset = false,
    this.footerSpacing = AppSpacing.s24,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? footer;
  final Widget? header;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final double footerSpacing;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: AppPagePadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (header != null) ...[
                      header!,
                      const SizedBox(height: AppSpacing.s24),
                    ],
                    Text(
                      title,
                      style: AppTypography.h1,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        subtitle!,
                        style: AppTypography.body,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s24),
                    body,
                  ],
                ),
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s8,
                AppSpacing.s16,
                footerSpacing,
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}