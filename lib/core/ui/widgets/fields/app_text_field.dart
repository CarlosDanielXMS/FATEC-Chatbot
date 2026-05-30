import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_field_error_text.dart';
import 'app_field_hint.dart';
import 'app_field_label.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hintText,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText = widget.obscureText;

  bool get _hasError => widget.errorText?.trim().isNotEmpty ?? false;
  bool get _hasHelper => widget.helperText?.trim().isNotEmpty ?? false;
  bool get _isPassword => widget.obscureText;

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = Theme.of(context).inputDecorationTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(
          label: widget.label,
          required: widget.required,
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          maxLines: _isPassword ? 1 : widget.maxLines,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          cursorColor: _hasError ? AppColors.error : AppColors.primary,
          style: AppTypography.body.copyWith(
            color: _hasError ? AppColors.error : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: null,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            enabledBorder: _hasError ? inputTheme.errorBorder : null,
            focusedBorder: _hasError ? inputTheme.focusedErrorBorder : null,
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: AppSpacing.s8),
          AppFieldErrorText(widget.errorText!),
        ] else if (_hasHelper) ...[
          const SizedBox(height: AppSpacing.s8),
          AppFieldHint(widget.helperText!),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (!_isPassword) return widget.suffixIcon;

    return IconButton(
      onPressed: widget.enabled ? _togglePasswordVisibility : null,
      tooltip: _obscureText ? 'Mostrar senha' : 'Ocultar senha',
      icon: Image.asset(
        _obscureText
            ? 'assets/icons/tabler-icon-eye-closed.png'
            : 'assets/icons/tabler-icon-eye.png',
        width: 22,
        height: 22,
        color: AppColors.textSecondary,
      ),
    );
  }
}