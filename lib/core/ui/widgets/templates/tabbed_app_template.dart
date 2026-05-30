import 'package:chatbot/core/ui/theme/app_colors.dart';
import 'package:chatbot/core/ui/widgets/layout/app_scaffold.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class TabbedAppTemplate extends StatelessWidget {
  const TabbedAppTemplate({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final Widget body;
  final int currentIndex;
  final List<AppBottomNavigationItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.background,
      body: body,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        items: items,
        onTap: onTap,
      ),
    );
  }
}