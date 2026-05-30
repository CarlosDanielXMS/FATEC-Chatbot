import 'package:chatbot/core/routing/app_routes.dart';
import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/buttons/app_button.dart';
import 'package:chatbot/core/ui/widgets/feedback/feedback.dart';
import 'package:chatbot/core/ui/widgets/fields/fields.dart';
import 'package:chatbot/core/validation/validators/positive_decimal_validator.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:chatbot/features/patient/domain/repositories/medication_repository.dart';
import 'package:chatbot/features/patient/domain/enums/medication_dosage_unit.dart';
import 'package:chatbot/features/patient/domain/enums/medication_duration_type.dart';
import 'package:chatbot/features/patient/domain/enums/medication_recurrence.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_page_header.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_selected_name_header.dart';
import 'package:chatbot/features/patient/presentation/widgets/medication_suggestion_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MedicationFormPage extends StatefulWidget {
  const MedicationFormPage({
    super.key,
    required this.medicationRepository,
    this.medicationId,
  });

  final MedicationRepository medicationRepository;
  final String? medicationId;

  @override
  State<MedicationFormPage> createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends State<MedicationFormPage> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();

  Future<Medication>? _medicationFuture;

  int _stepIndex = 0;

  MedicationDosageUnit? _selectedUnit;
  MedicationRecurrence? _selectedRecurrence;
  MedicationDurationType? _selectedDurationType;
  int? _selectedDurationDays;
  TimeOfDay? _selectedTime;

  bool _submitted = false;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  bool _initialValueApplied = false;
  bool _saved = false;

  bool get _isEditing => widget.medicationId?.trim().isNotEmpty == true;
  bool get _isNameStep => _stepIndex == 0;
  bool get _isDosageStep => _stepIndex == 1;
  bool get _isScheduleStep => _stepIndex == 2;
  bool get _isDurationStep => _stepIndex == 3;
  bool get _isReviewStep => _stepIndex == 4;

  static const _totalSteps = 5;

  static const _units = MedicationDosageUnit.values;
  static const _recurrences = MedicationRecurrence.values;

  static const _durations = [
    _MedicationDuration.continuous(),
    _MedicationDuration.fixedDays(3),
    _MedicationDuration.fixedDays(5),
    _MedicationDuration.fixedDays(7),
    _MedicationDuration.fixedDays(30),
    _MedicationDuration.fixedDays(60),
  ];

  String get _normalizedName {
    return _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  double? get _doseAmount {
    final normalized = _doseController.text.trim().replaceAll(',', '.');

    return double.tryParse(normalized);
  }

  String get _formattedTime {
    final time = _selectedTime;

    if (time == null) return '';

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  double get _progressValue {
    return (_stepIndex + 1) / _totalSteps;
  }

  String? get _nameError {
    if (!_submitted || !_isNameStep) return null;

    if (_normalizedName.isEmpty) return 'Informe o nome do medicamento.';

    return null;
  }

  String? get _doseError {
    if (!_submitted || !_isDosageStep) return null;

    final validation = PositiveDecimalValidator.validate(_doseController.text);

    return validation.errorMessage;
  }

  String? get _unitError {
    if (!_submitted || !_isDosageStep) return null;

    if (_selectedUnit == null) return 'Informe a unidade da dose.';

    return null;
  }

  String? get _timeError {
    if (!_submitted || !_isScheduleStep) return null;

    if (_selectedTime == null) return 'Informe o horário inicial.';

    return null;
  }

  String? get _recurrenceError {
    if (!_submitted || !_isScheduleStep) return null;

    if (_selectedRecurrence == null) return 'Informe a recorrência.';

    return null;
  }

  String? get _durationError {
    if (!_submitted || !_isDurationStep) return null;

    if (_selectedDurationType == null) {
      return 'Informe a duração do tratamento.';
    }

    return null;
  }

  bool get _canContinueCurrentStep {
    if (_isNameStep) return _normalizedName.isNotEmpty;

    if (_isDosageStep) {
      return _doseAmount != null && _doseAmount! > 0 && _selectedUnit != null;
    }

    if (_isScheduleStep) {
      return _selectedTime != null && _selectedRecurrence != null;
    }

    if (_isDurationStep) return _selectedDurationType != null;

    return true;
  }

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _medicationFuture = widget.medicationRepository.getMedicationById(widget.medicationId!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _applyInitialMedication(Medication medication) {
    if (_initialValueApplied) return;

    _initialValueApplied = true;

    _nameController.text = medication.name;

    final dosageAmount = medication.dosageAmount;
    if (dosageAmount != null) {
      _doseController.text = dosageAmount % 1 == 0
          ? dosageAmount.toInt().toString()
          : dosageAmount.toString().replaceAll('.', ',');
    }

    _selectedUnit = medication.dosageUnit;
    _selectedRecurrence = medication.recurrence;
    _selectedDurationType = medication.durationType;
    _selectedDurationDays = medication.durationDays;
    _selectedTime = _parseTime(medication.initialTime);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;

    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _nameController.text = suggestion;
      _nameController.selection = TextSelection.collapsed(
        offset: suggestion.length,
      );
    });
  }

  void _goToNameStep() {
    setState(() {
      _submitted = false;
      _stepIndex = 0;
    });
  }

  void _goBack() {
    if (_saved) {
      context.go(AppRoutes.patientMedications);
      return;
    }

    if (_stepIndex > 0) {
      setState(() {
        _submitted = false;
        _stepIndex--;
      });
      return;
    }

    context.go(AppRoutes.patientMedications);
  }

  void _goNext() {
    setState(() {
      _submitted = true;
    });

    if (!_canContinueCurrentStep) return;

    if (_isReviewStep) {
      _submit();
      return;
    }

    setState(() {
      _submitted = false;
      _stepIndex++;
    });
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 20, minute: 0),
      helpText: 'Horário inicial',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (time == null) return;

    setState(() {
      _selectedTime = time;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting ||
        _doseAmount == null ||
        _selectedUnit == null ||
        _selectedRecurrence == null ||
        _selectedDurationType == null ||
        _formattedTime.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditing) {
        await widget.medicationRepository.updateMedication(
          medicationId: widget.medicationId!,
          name: _normalizedName,
          dosageAmount: _doseAmount!,
          dosageUnit: _selectedUnit!,
          initialTime: _formattedTime,
          recurrence: _selectedRecurrence!,
          durationType: _selectedDurationType!,
          durationDays: _selectedDurationDays,
        );
      } else {
        await widget.medicationRepository.createMedication(
          name: _normalizedName,
          dosageAmount: _doseAmount!,
          dosageUnit: _selectedUnit!,
          initialTime: _formattedTime,
          recurrence: _selectedRecurrence!,
          durationType: _selectedDurationType!,
          durationDays: _selectedDurationDays,
        );
      }

      if (!mounted) return;

      setState(() {
        _saved = true;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o medicamento.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteMedication() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover medicamento'),
          content: const Text('Deseja remover este medicamento da sua lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || _isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await widget.medicationRepository.deleteMedication(widget.medicationId!);

      if (!mounted) return;

      context.go(AppRoutes.patientMedications);
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _newMedication() {
    setState(() {
      _stepIndex = 0;
      _submitted = false;
      _saved = false;
      _initialValueApplied = false;
      _selectedUnit = null;
      _selectedRecurrence = null;
      _selectedDurationType = null;
      _selectedDurationDays = null;
      _selectedTime = null;
      _nameController.clear();
      _doseController.clear();
    });
  }

  void _finish() {
    context.go(AppRoutes.patientMedications);
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return FutureBuilder<Medication>(
        future: _medicationFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppFeedbackState.error(
              title: 'Medicamento não encontrado',
              description:
                  'Não foi possível carregar os dados deste medicamento.',
              actionLabel: 'Voltar',
              onActionPressed: _finish,
            );
          }

          if (!snapshot.hasData) {
            return const AppLoading();
          }

          _applyInitialMedication(snapshot.data!);

          return _saved ? _buildSuccess() : _buildFlow();
        },
      );
    }

    return _saved ? _buildSuccess() : _buildFlow();
  }

  Widget _buildFlow() {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          MedicationPageHeader(
            title: _isEditing ? 'Editar Medicamento' : 'Novo Medicamento',
            showBackButton: true,
            showProgress: true,
            progressValue: _progressValue,
            onBackPressed: _goBack,
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s24,
              ),
              child: AnimatedSwitcher(
                duration: AppDurations.normal,
                child: _buildStep(),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildStep() {
    if (_isNameStep) return _buildNameStep();
    if (_isDosageStep) return _buildDosageStep();
    if (_isScheduleStep) return _buildScheduleStep();
    if (_isDurationStep) return _buildDurationStep();

    return _buildReviewStep();
  }

  Widget _buildNameStep() {
    final hasTypedName = _nameController.text.trim().isNotEmpty;

    return Column(
      key: const ValueKey('name-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasTypedName)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.s64,
              bottom: AppSpacing.s32,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/medicamentos.png',
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),
        AppTextField(
          label: 'Digite o nome do medicamento',
          hintText: 'Dipirona, Amoxilina...',
          controller: _nameController,
          errorText: _nameError,
          textInputAction: TextInputAction.done,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textSecondary,
              ),
              IconButton(
                tooltip: 'Scanner indisponível nesta etapa',
                onPressed: null,
                icon: const Icon(
                  Icons.photo_camera_outlined,
                  size: 19,
                ),
              ),
            ],
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _goNext(),
        ),
        MedicationSuggestionList(
          query: _nameController.text,
          onSelected: _selectSuggestion,
        ),
      ],
    );
  }

  Widget _buildDosageStep() {
    return Column(
      key: const ValueKey('dosage-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicationSelectedNameHeader(
          name: _normalizedName,
          onEditPressed: _goToNameStep,
        ),
        const SizedBox(height: AppSpacing.s24),
        AppTextField(
          label: 'Quantidade por dose',
          controller: _doseController,
          hintText: 'Ex. 1',
          errorText: _doseError,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
          ],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.s20),
        Text(
          'Unidade da dose',
          style: AppTypography.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        _MedicationDropdown(
          value: _selectedUnit?.label,
          hint: 'Comprimido, cápsula, gotas...',
          items: _units.map((unit) => unit.label).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedUnit = _units.firstWhere(
                (unit) => unit.label == value,
              );
            });
          },
        ),
        if (_unitError != null) ...[
          const SizedBox(height: AppSpacing.s8),
          AppFieldErrorText(_unitError!),
        ],
      ],
    );
  }

  Widget _buildScheduleStep() {
    return Column(
      key: const ValueKey('schedule-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicationSelectedNameHeader(
          name: _normalizedName,
          onEditPressed: _goToNameStep,
        ),
        const SizedBox(height: AppSpacing.s24),
        Text(
          'Horário inicial',
          style: AppTypography.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        InkWell(
          onTap: _selectTime,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _timeError == null ? AppColors.border : AppColors.error,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _formattedTime.isEmpty ? '20:00' : _formattedTime,
                  style: AppTypography.h3.copyWith(
                    color: _formattedTime.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        ),
        if (_timeError != null) ...[
          const SizedBox(height: AppSpacing.s8),
          AppFieldErrorText(_timeError!),
        ],
        const SizedBox(height: AppSpacing.s20),
        Text(
          'Recorrência',
          style: AppTypography.label.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        _MedicationDropdown(
          value: _selectedRecurrence?.label,
          hint: 'Selecione a recorrência',
          items: _recurrences.map((recurrence) => recurrence.label).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedRecurrence = _recurrences.firstWhere(
                (recurrence) => recurrence.label == value,
              );
            });
          },
        ),
        if (_recurrenceError != null) ...[
          const SizedBox(height: AppSpacing.s8),
          AppFieldErrorText(_recurrenceError!),
        ],
      ],
    );
  }

  Widget _buildDurationStep() {
    return Column(
      key: const ValueKey('duration-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicationSelectedNameHeader(
          name: _normalizedName,
          onEditPressed: _goToNameStep,
        ),
        const SizedBox(height: AppSpacing.s24),
        Text(
          'Duração',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        ..._durations.map(
          (duration) {
            final selected = duration.type == _selectedDurationType &&
                duration.days == _selectedDurationDays;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: _MedicationDurationOption(
                label: duration.label,
                selected: selected,
                onTap: () {
                  setState(() {
                    _selectedDurationType = duration.type;
                    _selectedDurationDays = duration.days;
                  });
                },
              ),
            );
          },
        ),
        if (_durationError != null) ...[
          const SizedBox(height: AppSpacing.s4),
          AppFieldErrorText(_durationError!),
        ],
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      key: const ValueKey('review-step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revisão',
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
        _ReviewField(
          label: 'Nome remédio',
          value: _normalizedName,
          onEdit: _goToNameStep,
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          children: [
            Expanded(
              child: _ReviewField(
                label: 'Dosagem',
                value: '${_doseController.text} ${_selectedUnit?.label ?? ''}',
                onEdit: () {
                  setState(() {
                    _submitted = false;
                    _stepIndex = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _ReviewField(
                label: 'Horário',
                value: _formattedTime,
                onEdit: () {
                  setState(() {
                    _submitted = false;
                    _stepIndex = 2;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          children: [
            Expanded(
              child: _ReviewField(
                label: 'Recorrência',
                value: _selectedRecurrence?.label ?? '',
                onEdit: () {
                  setState(() {
                    _submitted = false;
                    _stepIndex = 2;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _ReviewField(
                label: 'Duração',
                value: _selectedDurationType == MedicationDurationType.continuous
                    ? 'Uso contínuo'
                    : '${_selectedDurationDays ?? ''} dias',
                onEdit: () {
                  setState(() {
                    _submitted = false;
                    _stepIndex = 3;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton.primary(
            label: _isReviewStep
                ? (_isSubmitting ? 'Salvando...' : 'Salvar')
                : 'Avançar',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting || _isDeleting ? null : _goNext,
          ),
          if (_isEditing) ...[
            const SizedBox(height: AppSpacing.s12),
            AppButton.secondary(
              label: 'Remover medicamento',
              isLoading: _isDeleting,
              onPressed: _isSubmitting || _isDeleting ? null : _deleteMedication,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s24,
        ),
        child: Column(
          children: [
            MedicationPageHeader(
              title: 'Remédio - $_normalizedName',
              showBackButton: false,
            ),
            const Spacer(),
            Image.asset('assets/images/lista-de-controle.png'),
            const SizedBox(height: AppSpacing.s32),
            Text(
              'Cadastro realizado\ncom sucesso!',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            AppButton.secondary(
              label: 'Novo Medicamento',
              onPressed: _newMedication,
            ),
            const SizedBox(height: AppSpacing.s12),
            AppButton.primary(
              label: 'Concluir',
              onPressed: _finish,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationDropdown extends StatelessWidget {
  const _MedicationDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        errorText: null,
      ),
    );
  }
}

class _MedicationDurationOption extends StatelessWidget {
  const _MedicationDurationOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.p01 : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.p05 : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.p05 : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s12),
              Text(
                label,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Image.asset(
                  'assets/icons/tabler-icon-edit.png',
                  width: 18,
                  height: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MedicationDuration {
  const _MedicationDuration._({
    required this.label,
    required this.type,
    required this.days,
  });

  const _MedicationDuration.continuous()
      : this._(
          label: 'Uso contínuo',
          type: MedicationDurationType.continuous,
          days: null,
        );

  const _MedicationDuration.fixedDays(int days)
      : this._(
          label: '$days dias',
          type: MedicationDurationType.fixedDays,
          days: days,
        );

  final String label;
  final MedicationDurationType type;
  final int? days;
}