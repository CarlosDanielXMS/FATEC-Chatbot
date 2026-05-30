import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

class MedicationSuggestionList extends StatelessWidget {
  const MedicationSuggestionList({
    super.key,
    required this.query,
    required this.onSelected,
  });

  final String query;
  final ValueChanged<String> onSelected;

  static const _baseSuggestions = [
    'Cisplatina',
    'Cisplatina Eurofarma',
    'Cisplatina Cristália',
    'Cisplatina EMS',
    'Dipirona',
    'Paracetamol',
    'Amoxicilina',
    'Losartana',
  ];

  List<String> get _suggestions {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) return const [];

    final filtered = _baseSuggestions.where((suggestion) {
      return suggestion.toLowerCase().contains(normalizedQuery);
    }).toList();

    if (filtered.isNotEmpty) return filtered.take(4).toList();

    return [query.trim()];
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s20),
        Text(
          'Você procura por',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        ...suggestions.map(
          (suggestion) {
            return InkWell(
              onTap: () => onSelected(suggestion),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s10,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}