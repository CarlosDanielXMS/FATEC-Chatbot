import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:flutter/material.dart';

class PatientHomeNextAlarmCard extends StatelessWidget {
  const PatientHomeNextAlarmCard({
    super.key,
    required this.alarm,
    required this.onSeeAlarmsPressed,
    required this.onAddMedicationPressed,
  });

  final Alarm? alarm;
  final VoidCallback onSeeAlarmsPressed;
  final VoidCallback onAddMedicationPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.medium,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offset,
          child: child,
        );
      },
      child: alarm == null
          ? _EmptyAlarmCard(
              key: const ValueKey('empty-next-alarm'),
              onTap: onAddMedicationPressed,
            )
          : _FilledAlarmCard(
              key: ValueKey(alarm!.id),
              alarm: alarm!,
              onTap: onSeeAlarmsPressed,
            ),
    );
  }
}

class _FilledAlarmCard extends StatelessWidget {
  const _FilledAlarmCard({
    super.key,
    required this.alarm,
    required this.onTap,
  });

  final Alarm alarm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AlarmCardFrame(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -22,
            bottom: -14,
            child: Image.asset(
              'assets/images/despertador.png',
              width: 172,
              height: 142,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            top: 18,
            right: 18,
            child: _AlarmArrow(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 150, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AlarmTitle(),
                const SizedBox(height: 20),
                Text(
                  alarm.medicationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: AppColors.p05,
                    fontSize: 17,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      alarm.time,
                      style: AppTypography.h1.copyWith(
                        color: AppColors.p05,
                        fontSize: 52,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlarmCard extends StatelessWidget {
  const _EmptyAlarmCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AlarmCardFrame(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 24,
            bottom: 16,
            child: Image.asset(
              'assets/images/despertador.png',
              width: 120,
              height: 102,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            top: 18,
            right: 18,
            child: _AlarmArrow(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 142, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AlarmTitle(),
                const SizedBox(height: 20),
                Text(
                  'Nenhum alarme definido',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: AppColors.p05,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Adicionar medicamento',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: AppColors.p05,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlarmCardFrame extends StatelessWidget {
  const _AlarmCardFrame({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  static const _height = 148.0;
  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.p01,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: SizedBox(
          width: double.infinity,
          height: _height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AlarmTitle extends StatelessWidget {
  const _AlarmTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Próximo Alarme',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.h2.copyWith(
        color: AppColors.p05,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}

class _AlarmArrow extends StatelessWidget {
  const _AlarmArrow();

  @override
  Widget build(BuildContext context) {
    return Text(
      '›',
      style: AppTypography.h2.copyWith(
        color: AppColors.p05,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}