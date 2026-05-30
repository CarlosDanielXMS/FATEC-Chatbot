import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AppBottomNavigationItem {
  const AppBottomNavigationItem({
    required this.iconAsset,
    required this.label,
    String? activeIconAsset,
  }) : activeIconAsset = activeIconAsset ?? iconAsset;

  final String iconAsset;
  final String activeIconAsset;
  final String label;
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<AppBottomNavigationItem> items;
  final ValueChanged<int> onTap;

  static const _barHeight = 66.0;
  static const _indicatorHeight = 2.0;
  static const _iconSize = 23.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(items.length, (index) {
              return Expanded(
                child: _AppBottomNavigationTile(
                  item: items[index],
                  selected: index == currentIndex,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AppBottomNavigationTile extends StatelessWidget {
  const _AppBottomNavigationTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.p04 : AppColors.b03;
    final iconAsset = selected ? item.activeIconAsset : item.iconAsset;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selected ? null : onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.04),
        highlightColor: AppColors.primary.withValues(alpha: 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedOpacity(
              duration: AppDurations.fast,
              curve: Curves.easeOut,
              opacity: selected ? 1 : 0,
              child: const SizedBox(
                height: AppBottomNavigationBar._indicatorHeight,
                width: double.infinity,
                child: ColoredBox(
                  color: AppColors.p04,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Image.asset(
              iconAsset,
              width: AppBottomNavigationBar._iconSize,
              height: AppBottomNavigationBar._iconSize,
              color: color,
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}