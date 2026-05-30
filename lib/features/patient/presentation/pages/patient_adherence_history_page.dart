import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:chatbot/core/ui/widgets/feedback/feedback.dart';
import 'package:chatbot/core/ui/widgets/navigation/app_top_bar.dart';
import 'package:chatbot/features/patient/domain/entities/adherence_event.dart';
import 'package:chatbot/features/patient/domain/repositories/adherence_event_repository.dart';
import 'package:chatbot/features/patient/presentation/widgets/adherence_history_card.dart';
import 'package:flutter/material.dart';

class PatientAdherenceHistoryPage extends StatefulWidget {
  const PatientAdherenceHistoryPage({
    super.key,
    required this.adherenceEventRepository,
  });

  final AdherenceEventRepository adherenceEventRepository;

  @override
  State<PatientAdherenceHistoryPage> createState() {
    return _PatientAdherenceHistoryPageState();
  }
}

class _PatientAdherenceHistoryPageState
    extends State<PatientAdherenceHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          const AppTopBar(
            title: 'Histórico de adesão',
            showBackButton: true,
          ),
          Expanded(
            child: StreamBuilder<List<AdherenceEvent>>(
              stream: widget.adherenceEventRepository
                  .watchCurrentPatientAdherenceEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return AppFeedbackState.error(
                    title: 'Não foi possível carregar',
                    description: 'Tente novamente em alguns instantes.',
                    actionLabel: 'Recarregar',
                    onActionPressed: () => setState(() {}),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const AppLoading();
                }

                final events = snapshot.data ?? const <AdherenceEvent>[];

                if (events.isEmpty) {
                  return const AppFeedbackState.empty(
                    title: 'Nenhum registro ainda',
                    description:
                        'As respostas aos alarmes aparecerão aqui depois que você confirmar uma tomada.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s8,
                    AppSpacing.s16,
                    AppSpacing.s24,
                  ),
                  itemCount: events.length,
                  separatorBuilder: (_, _) {
                    return const SizedBox(height: AppSpacing.s12);
                  },
                  itemBuilder: (context, index) {
                    return AdherenceHistoryCard(
                      event: events[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}