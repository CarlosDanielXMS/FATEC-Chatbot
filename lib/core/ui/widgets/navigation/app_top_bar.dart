import 'package:flutter/material.dart';

import 'app_back_button.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.leading,
    this.actions,
    this.centerTitle = true,
  });

  final String title;
  final bool showBackButton;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading ?? (showBackButton ? const AppBackButton() : null),
      title: Text(title),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}