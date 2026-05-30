import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/fields/app_field_error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MedicationTimeSelector extends StatefulWidget {
  const MedicationTimeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;
  final String? errorText;

  @override
  State<MedicationTimeSelector> createState() => _MedicationTimeSelectorState();
}

class _MedicationTimeSelectorState extends State<MedicationTimeSelector> {
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;

  bool get _hasError => widget.errorText?.trim().isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();

    _hourController = TextEditingController(
      text: _formatHour(widget.value),
    );

    _minuteController = TextEditingController(
      text: _formatMinute(widget.value),
    );
  }

  @override
  void didUpdateWidget(covariant MedicationTimeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _hourController.text = _formatHour(widget.value);
      _minuteController.text = _formatMinute(widget.value);
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String _formatHour(TimeOfDay? value) {
    return (value?.hour ?? 20).toString().padLeft(2, '0');
  }

  String _formatMinute(TimeOfDay? value) {
    return (value?.minute ?? 0).toString().padLeft(2, '0');
  }

  void _onChanged() {
    final hour = int.tryParse(_hourController.text);
    final minute = int.tryParse(_minuteController.text);

    if (hour == null || minute == null) {
      widget.onChanged(null);
      return;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      widget.onChanged(null);
      return;
    }

    widget.onChanged(
      TimeOfDay(
        hour: hour,
        minute: minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _TimePartField(
                controller: _hourController,
                isActive: true,
                hasError: _hasError,
                onChanged: _onChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              ':',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: _TimePartField(
                controller: _minuteController,
                isActive: false,
                hasError: _hasError,
                onChanged: _onChanged,
              ),
            ),
          ],
        ),
        if (_hasError) ...[
          const SizedBox(height: AppSpacing.s8),
          AppFieldErrorText(widget.errorText!),
        ],
      ],
    );
  }
}

class _TimePartField extends StatelessWidget {
  const _TimePartField({
    required this.controller,
    required this.isActive,
    required this.hasError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isActive;
  final bool hasError;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive ? AppColors.p01 : AppColors.background;
    final borderColor = hasError ? AppColors.error : AppColors.border;

    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 2,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        onChanged: (_) => onChanged(),
        style: AppTypography.h2.copyWith(
          color: AppColors.p05,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: backgroundColor,
          contentPadding: EdgeInsets.zero,
          errorText: null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(
              color: hasError ? AppColors.error : AppColors.p05,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}