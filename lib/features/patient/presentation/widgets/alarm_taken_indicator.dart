import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AlarmTakenIndicator extends StatelessWidget {
  const AlarmTakenIndicator({
    super.key,
    required this.enabled,
  });

  final bool enabled;

  static const _boxSize = 11.0;
  static const _boxRadius = 1.5;
  static const _boxBorderWidth = 0.8;
  static const _labelSpacing = 5.0;
  static const _labelFontSize = 10.0;

  static const _activeColor = AppColors.p05;
  static const _disabledColor = Color(0xFF77736F);

  @override
  Widget build(BuildContext context) {
    final color = enabled ? _activeColor : _disabledColor;

    return IgnorePointer(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: _boxSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(_boxRadius),
                border: Border.all(
                  color: color,
                  width: _boxBorderWidth,
                ),
              ),
            ),
          ),
          const SizedBox(width: _labelSpacing),
          Text(
            'Tomei',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: color,
              fontSize: _labelFontSize,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}