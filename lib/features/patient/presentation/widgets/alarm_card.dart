import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/presentation/widgets/alarm_status_switch.dart';
import 'package:flutter/material.dart';

class AlarmCard extends StatelessWidget {
  const AlarmCard({
    super.key,
    required this.alarm,
    required this.isUpdating,
    required this.isTaking,
    required this.onEnabledChanged,
    required this.onTakenPressed,
  });

  final Alarm alarm;
  final bool isUpdating;
  final bool isTaking;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onTakenPressed;

  static const _height = 120.0;
  static const _radius = AppRadius.sm;
  static const _borderWidth = 1.4;

  static const _horizontalPadding = AppSpacing.s14;
  static const _topPadding = AppSpacing.s12;
  static const _bottomPadding = AppSpacing.s10;

  static const _headerHeight = 40.0;
  static const _footerHeight = 24.0;
  static const _verticalGap = AppSpacing.s10;

  static const _timeFontSize = 37.0;
  static const _labelFontSize = 15.0;
  static const _timeLetterSpacing = -0.6;

  static const _takenBoxSize = 17.0;
  static const _takenBoxRadius = 2.0;
  static const _takenBoxBorderWidth = 1.4;

  static const _disabledBackgroundColor = Color(0xFFCFCDCB);
  static const _disabledContentColor = Color(0xFF575553);
  static const _disabledDividerColor = Color(0xFF8D8985);

  bool get _isEnabled => alarm.enabled;

  bool get _canTake {
    return _isEnabled && !isUpdating && !isTaking;
  }

  Color get _backgroundColor {
    return _isEnabled ? AppColors.background : _disabledBackgroundColor;
  }

  Color get _borderColor {
    return _isEnabled ? AppColors.p05 : Colors.transparent;
  }

  Color get _contentColor {
    return _isEnabled ? AppColors.p05 : _disabledContentColor;
  }

  Color get _dividerColor {
    return _isEnabled ? AppColors.p02 : _disabledDividerColor;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: isUpdating || isTaking ? 0.58 : 1,
      child: Container(
        height: _height,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          _horizontalPadding,
          _topPadding,
          _horizontalPadding,
          _bottomPadding,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: _borderColor,
            width: _isEnabled ? _borderWidth : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _headerHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      alarm.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h1.copyWith(
                        color: _contentColor,
                        fontSize: _timeFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        letterSpacing: _timeLetterSpacing,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  AlarmStatusSwitch(
                    value: alarm.enabled,
                    enabled: !isUpdating && !isTaking,
                    onChanged: onEnabledChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(height: _verticalGap),
            SizedBox(
              height: 1,
              child: ColoredBox(color: _dividerColor),
            ),
            const SizedBox(height: _verticalGap),
            SizedBox(
              height: _footerHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      alarm.medicationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        color: _contentColor,
                        fontSize: _labelFontSize,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    child: InkWell(
                      onTap: _canTake ? onTakenPressed : null,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4,
                          vertical: AppSpacing.s2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox.square(
                              dimension: _takenBoxSize,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isTaking
                                      ? _contentColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    _takenBoxRadius,
                                  ),
                                  border: Border.all(
                                    color: _contentColor,
                                    width: _takenBoxBorderWidth,
                                  ),
                                ),
                                child: isTaking
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: AppColors.background,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Text(
                              isTaking ? 'Salvando' : 'Tomei',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body.copyWith(
                                color: _contentColor,
                                fontSize: _labelFontSize,
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}