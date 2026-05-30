import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class AlarmStatusSwitch extends StatelessWidget {
  const AlarmStatusSwitch({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  static const _width = 31.0;
  static const _height = 18.0;
  static const _thumbSize = 14.0;
  static const _thumbInset = 2.0;

  static const _activeTrackColor = Color(0xFF4CAF50);
  static const _inactiveTrackColor = Color(0xFFB8B5B2);
  static const _inactiveThumbColor = Color(0xFF77736F);

  @override
  Widget build(BuildContext context) {
    final thumbLeft = value
        ? _width - _thumbSize - _thumbInset
        : _thumbInset;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged(!value) : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.72,
        child: SizedBox(
          width: _width,
          height: _height,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: value ? _activeTrackColor : _inactiveTrackColor,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: value ? _activeTrackColor : AppColors.b04,
                width: value ? 0 : 0.8,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: AppDurations.fast,
                  curve: Curves.easeOut,
                  left: thumbLeft,
                  top: _thumbInset,
                  child: SizedBox.square(
                    dimension: _thumbSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: value
                            ? AppColors.background
                            : _inactiveThumbColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}