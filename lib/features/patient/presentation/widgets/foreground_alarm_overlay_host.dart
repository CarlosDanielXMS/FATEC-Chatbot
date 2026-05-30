import 'dart:async';

import 'package:chatbot/core/ui/theme/app_durations.dart';
import 'package:chatbot/features/patient/domain/entities/alarm.dart';
import 'package:chatbot/features/patient/domain/enums/adherence_event_type.dart';
import 'package:chatbot/features/patient/domain/repositories/adherence_event_repository.dart';
import 'package:chatbot/features/patient/domain/repositories/alarm_repository.dart';
import 'package:chatbot/features/patient/presentation/widgets/active_alarm_overlay.dart';
import 'package:flutter/material.dart';

class ForegroundAlarmOverlayHost extends StatefulWidget {
  const ForegroundAlarmOverlayHost({
    super.key,
    required this.child,
    required this.alarmRepository,
    required this.adherenceEventRepository,
  });

  final Widget child;
  final AlarmRepository alarmRepository;
  final AdherenceEventRepository adherenceEventRepository;

  @override
  State<ForegroundAlarmOverlayHost> createState() {
    return _ForegroundAlarmOverlayHostState();
  }
}

class _ForegroundAlarmOverlayHostState
    extends State<ForegroundAlarmOverlayHost> {
  static const _refreshInterval = AppDurations.medium;
  static const _switchDelay = AppDurations.medium;
  static const _postponeInterval = Duration(minutes: 10);
  static const _maxPostponeAttempts = 5;

  final Set<String> _dismissedAlarmIds = {};
  final Map<String, int> _postponeAttemptsByAlarmId = {};
  final Map<String, DateTime> _postponedUntilByAlarmId = {};

  StreamSubscription<List<Alarm>>? _alarmsSubscription;
  Timer? _timer;

  List<Alarm> _alarms = const [];
  DateTime _now = DateTime.now();
  Alarm? _activeAlarm;
  bool _isSwitchingAlarm = false;

  @override
  void initState() {
    super.initState();

    _alarmsSubscription = widget.alarmRepository
        .watchCurrentPatientAlarms()
        .listen(_onAlarmsChanged);

    _timer = Timer.periodic(_refreshInterval, (_) {
      if (!mounted) return;

      setState(() {
        _now = DateTime.now();
        _selectActiveAlarmIfNeeded();
      });
    });
  }

  @override
  void dispose() {
    _alarmsSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _onAlarmsChanged(List<Alarm> alarms) {
    if (!mounted) return;

    setState(() {
      _alarms = alarms;
      _selectActiveAlarmIfNeeded();
    });
  }

  void _selectActiveAlarmIfNeeded() {
    if (_isSwitchingAlarm) return;

    if (_activeAlarm != null && _isStillValidActiveAlarm(_activeAlarm!)) {
      return;
    }

    _activeAlarm = _selectNextDueAlarm();
  }

  bool _isStillValidActiveAlarm(Alarm alarm) {
    return _alarms.any((item) {
      return item.id == alarm.id && _isDueAlarm(item);
    });
  }

  Alarm? _selectNextDueAlarm() {
    final dueAlarms = _alarms.where(_isDueAlarm).toList()
      ..sort((first, second) {
        return first.scheduledAt.compareTo(second.scheduledAt);
      });

    if (dueAlarms.isEmpty) return null;

    return dueAlarms.first;
  }

  bool _isDueAlarm(Alarm alarm) {
    if (!alarm.enabled) return false;
    if (_dismissedAlarmIds.contains(alarm.id)) return false;
    if (alarm.scheduledAt.isAfter(_now)) return false;

    final postponedUntil = _postponedUntilByAlarmId[alarm.id];
    if (postponedUntil != null && postponedUntil.isAfter(_now)) {
      return false;
    }

    final attempts = _postponeAttemptsByAlarmId[alarm.id] ?? 0;

    return attempts < _maxPostponeAttempts;
  }

  Future<void> _submitAlarmAction(AdherenceEventType action) async {
    final alarm = _activeAlarm;
    if (alarm == null) return;

    await widget.adherenceEventRepository.createForAlarm(
      alarmId: alarm.id,
      action: action,
    );

    if (action.isTaken) {
      await widget.alarmRepository.completeAlarm(alarm.id);

      _dismissedAlarmIds.add(alarm.id);
      _postponeAttemptsByAlarmId.remove(alarm.id);
      _postponedUntilByAlarmId.remove(alarm.id);
      return;
    }

    if (action.isPostponed) {
      final nextAttempt = (_postponeAttemptsByAlarmId[alarm.id] ?? 0) + 1;
      _postponeAttemptsByAlarmId[alarm.id] = nextAttempt;

      if (nextAttempt >= _maxPostponeAttempts) {
        _dismissedAlarmIds.add(alarm.id);
        _postponedUntilByAlarmId.remove(alarm.id);
        return;
      }

      _postponedUntilByAlarmId[alarm.id] = DateTime.now().add(
        _postponeInterval,
      );
    }
  }

  Future<void> _completeActiveAlarm() async {
    final completedAlarm = _activeAlarm;
    if (completedAlarm == null || _isSwitchingAlarm) return;

    setState(() {
      _isSwitchingAlarm = true;
      _activeAlarm = null;
    });

    await Future<void>.delayed(_switchDelay);

    if (!mounted) return;

    setState(() {
      _isSwitchingAlarm = false;
      _activeAlarm = _selectNextDueAlarm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeAlarm = _activeAlarm;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: activeAlarm == null,
            child: AnimatedSwitcher(
              duration: AppDurations.medium,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              child: activeAlarm == null
                  ? const SizedBox.shrink(
                      key: ValueKey('empty-active-alarm-overlay'),
                    )
                  : ActiveAlarmOverlay(
                      key: ValueKey(activeAlarm.id),
                      alarm: activeAlarm,
                      onSubmitted: _submitAlarmAction,
                      onCompleted: _completeActiveAlarm,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}