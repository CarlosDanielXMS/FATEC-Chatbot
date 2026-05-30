import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:flutter/material.dart';

class ActiveAlarmOverlay extends StatefulWidget {
  const ActiveAlarmOverlay({
    super.key,
    required this.alarm,
    required this.onSubmitted,
    required this.onCompleted,
  });

  final Alarm alarm;
  final Future<void> Function(AdherenceEventType action) onSubmitted;
  final VoidCallback onCompleted;

  @override
  State<ActiveAlarmOverlay> createState() => _ActiveAlarmOverlayState();
}

class _ActiveAlarmOverlayState extends State<ActiveAlarmOverlay> {
  static const _panelHeightFactor = 0.68;
  static const _panelRadius = 30.0;
  static const _panelBorderWidth = 2.0;

  static const _illustrationWidthFactor = 4 / 6;
  static const _maxIllustrationHeight = 190.0;

  static const _contentHorizontalPadding = AppSpacing.s24;
  static const _contentTopPadding = AppSpacing.s44;
  static const _contentBottomPadding = AppSpacing.s24;

  static const _optionsWidth = 210.0;
  static const _checkboxSize = 18.0;
  static const _buttonWidthFactor = 0.78;
  static const _successDelay = AppDurations.slow;

  AdherenceEventType? _selectedAction;
  bool _isSaving = false;
  bool _isSaved = false;
  String? _errorMessage;

  bool get _canSave {
    return _selectedAction != null && !_isSaving && !_isSaved;
  }

  bool get _hasError {
    return _errorMessage?.trim().isNotEmpty ?? false;
  }

  void _selectAction(AdherenceEventType action) {
    if (_isSaving || _isSaved) return;

    setState(() {
      _selectedAction = action;
      _errorMessage = null;
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;

    final action = _selectedAction!;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmitted(action);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      await Future<void>.delayed(_successDelay);

      if (!mounted) return;

      widget.onCompleted();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage =
            'Não foi possível salvar sua resposta. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: _panelHeightFactor,
        child: Material(
          color: AppColors.background,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: AppColors.b02,
              width: _panelBorderWidth,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_panelRadius),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                _contentHorizontalPadding,
                _contentTopPadding,
                _contentHorizontalPadding,
                _contentBottomPadding,
              ),
              child: AnimatedSwitcher(
                duration: AppDurations.normal,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _isSaved
                    ? _SavedContent(
                        key: const ValueKey('active-alarm-saved-content'),
                        alarm: widget.alarm,
                      )
                    : _buildFormContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      key: const ValueKey('active-alarm-form-content'),
      children: [
        _AlarmIllustration(
          widthFactor: _illustrationWidthFactor,
          maxHeight: _maxIllustrationHeight,
        ),
        const SizedBox(height: AppSpacing.s28),
        Text(
          'Você tomou o remédio ${widget.alarm.medicationName} '
          'programado para às ${widget.alarm.time}?',
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(
            color: AppColors.b06,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          'Marque sua resposta para manter seu histórico atualizado.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.b05,
            fontSize: 13,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.s28),
        SizedBox(
          width: _optionsWidth,
          child: Column(
            children: [
              _AdherenceActionOption(
                label: 'Tomei',
                selected: _selectedAction == AdherenceEventType.taken,
                enabled: !_isSaving,
                checkboxSize: _checkboxSize,
                onTap: () {
                  _selectAction(AdherenceEventType.taken);
                },
              ),
              const SizedBox(height: AppSpacing.s16),
              _AdherenceActionOption(
                label: 'Vou tomar depois',
                selected: _selectedAction == AdherenceEventType.postponed,
                enabled: !_isSaving,
                checkboxSize: _checkboxSize,
                onTap: () {
                  _selectAction(AdherenceEventType.postponed);
                },
              ),
            ],
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: AppSpacing.s16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const Spacer(),
        FractionallySizedBox(
          widthFactor: _buttonWidthFactor,
          child: AppButton.primary(
            label: _isSaving ? 'Salvando...' : 'Salvar',
            onPressed: _canSave ? _save : null,
            isLoading: _isSaving,
          ),
        ),
      ],
    );
  }
}

class _SavedContent extends StatelessWidget {
  const _SavedContent({
    super.key,
    required this.alarm,
  });

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const _AlarmIllustration(
          widthFactor: 0.58,
          maxHeight: 170,
        ),
        const SizedBox(height: AppSpacing.s28),
        Text(
          'Resposta salva',
          textAlign: TextAlign.center,
          style: AppTypography.h2.copyWith(
            color: AppColors.b06,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          'Sua resposta sobre ${alarm.medicationName} foi registrada.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.b05,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _AlarmIllustration extends StatelessWidget {
  const _AlarmIllustration({
    required this.widthFactor,
    required this.maxHeight,
  });

  final double widthFactor;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.asset(
          'assets/images/check-image.png',
          width: constraints.maxWidth * widthFactor,
          height: maxHeight,
          fit: BoxFit.contain,
        );
      },
    );
  }
}

class _AdherenceActionOption extends StatelessWidget {
  const _AdherenceActionOption({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.checkboxSize,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final double checkboxSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.b06 : AppColors.b03;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Row(
        children: [
          _CheckBoxMark(
            selected: selected,
            enabled: enabled,
            size: checkboxSize,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(
                color: color,
                fontSize: 16,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckBoxMark extends StatelessWidget {
  const _CheckBoxMark({
    required this.selected,
    required this.enabled,
    required this.size,
  });

  final bool selected;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderColor = enabled ? AppColors.borderStrong : AppColors.b03;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primary : borderColor,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: selected
            ? const Icon(
                Icons.check_rounded,
                size: 13,
                color: AppColors.textInverse,
              )
            : null,
      ),
    );
  }
}