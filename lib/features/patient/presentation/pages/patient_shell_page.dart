import 'package:chatbot/core/ui/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:chatbot/core/ui/widgets/templates/tabbed_app_template.dart';
import 'package:chatbot/features/patient/domain/repositories/adherence_event_repository.dart';
import 'package:chatbot/features/patient/domain/repositories/alarm_repository.dart';
import 'package:chatbot/features/patient/presentation/widgets/foreground_alarm_overlay_host.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientShellPage extends StatelessWidget {
  const PatientShellPage({
    super.key,
    required this.navigationShell,
    required this.alarmRepository,
    required this.adherenceEventRepository,
  });

  final StatefulNavigationShell navigationShell;
  final AlarmRepository alarmRepository;
  final AdherenceEventRepository adherenceEventRepository;

  static const _items = [
    AppBottomNavigationItem(
      iconAsset: 'assets/icons/tabler-icon-home.png',
      label: 'Home',
    ),
    AppBottomNavigationItem(
      iconAsset: 'assets/icons/tabler-icon-pill.png',
      label: 'Medicamentos',
    ),
    AppBottomNavigationItem(
      iconAsset: 'assets/icons/tabler-icon-alarm.png',
      label: 'Alarme',
    ),
    AppBottomNavigationItem(
      iconAsset: 'assets/icons/tabler-icon-user-circle.png',
      label: 'Perfil',
    ),
  ];

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ForegroundAlarmOverlayHost(
      alarmRepository: alarmRepository,
      adherenceEventRepository: adherenceEventRepository,
      child: TabbedAppTemplate(
        body: navigationShell,
        currentIndex: navigationShell.currentIndex,
        items: _items,
        onTap: _goToBranch,
      ),
    );
  }
}