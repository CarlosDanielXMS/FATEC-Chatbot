import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/entities/medication.dart';
import 'package:flutter/material.dart';

class PatientHomeWeekCalendar extends StatelessWidget {
  const PatientHomeWeekCalendar({
    super.key,
    required this.selectedDate,
    required this.alarms,
    required this.medications,
  });

  final DateTime selectedDate;
  final List<Alarm> alarms;
  final List<Medication> medications;

  static const _height = 44.0;
  static const _dotSize = 3.0;

  static const _dotColors = [
    AppColors.success,
    AppColors.s03,
    AppColors.p05,
  ];

  @override
  Widget build(BuildContext context) {
    final days = _currentWeek(selectedDate);

    return SizedBox(
      height: _height,
      child: Row(
        children: [
          for (var index = 0; index < days.length; index++) ...[
            Expanded(
              child: _CalendarDay(
                date: days[index],
                selected: _isSameDay(days[index], selectedDate),
                dotColors: _dotColorsFor(days[index]),
              ),
            ),
            if (index < days.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  List<DateTime> _currentWeek(DateTime reference) {
    final day = DateTime(reference.year, reference.month, reference.day);
    final start = day.subtract(Duration(days: day.weekday - DateTime.monday));

    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  List<Color> _dotColorsFor(DateTime date) {
    final medicationIds = alarms
        .where((alarm) => _isSameDay(alarm.scheduledAt, date))
        .map((alarm) => alarm.medicationId)
        .toSet();

    final colors = <Color>[];

    for (final medicationId in medicationIds) {
      final index = medications.indexWhere(
        (medication) => medication.id == medicationId,
      );

      if (index < 0) continue;

      colors.add(_dotColors[index % _dotColors.length]);
      if (colors.length == 3) break;
    }

    return colors;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.selected,
    required this.dotColors,
  });

  final DateTime date;
  final bool selected;
  final List<Color> dotColors;

  static const _weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.p05 : AppColors.b04;

    return Container(
      padding: const EdgeInsets.fromLTRB(3, 5, 3, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: selected ? AppColors.p02 : AppColors.border,
          width: selected ? 1.2 : 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _weekDays[date.weekday - 1],
            style: AppTypography.caption.copyWith(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MedicationDots(colors: dotColors),
              const SizedBox(width: 2),
              Text(
                date.day.toString(),
                style: AppTypography.h3.copyWith(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicationDots extends StatelessWidget {
  const _MedicationDots({
    required this.colors,
  });

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox(width: 3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((color) {
        return Container(
          width: PatientHomeWeekCalendar._dotSize,
          height: PatientHomeWeekCalendar._dotSize,
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        );
      }).toList(),
    );
  }
}