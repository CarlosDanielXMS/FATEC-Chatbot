import 'package:chatbot/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

enum _PatientHomeEducationCardVariant {
  sideEffectsShortcut,
  knowledgeBase,
  sideEffectsHistory,
}

class PatientHomeEducationCard extends StatelessWidget {
  const PatientHomeEducationCard._({
    super.key,
    required _PatientHomeEducationCardVariant variant,
    required this.title,
    required this.description,
    required this.onTap,
    this.imageAsset,
  }) : _variant = variant;

  const PatientHomeEducationCard.sideEffectsShortcut({
    Key? key,
    required VoidCallback onTap,
  }) : this._(
          key: key,
          variant: _PatientHomeEducationCardVariant.sideEffectsShortcut,
          title: 'Registre seus\nefeitos adversos',
          description: '',
          onTap: onTap,
        );

  const PatientHomeEducationCard.knowledgeBase({
    Key? key,
    required VoidCallback onTap,
  }) : this._(
          key: key,
          variant: _PatientHomeEducationCardVariant.knowledgeBase,
          title: 'Base Científica',
          description:
              'Aqui você encontra artigos seguros e confiáveis sobre seu caso clínico',
          imageAsset: 'assets/images/revista.png',
          onTap: onTap,
        );

  const PatientHomeEducationCard.sideEffectsHistory({
    Key? key,
    required VoidCallback onTap,
  }) : this._(
          key: key,
          variant: _PatientHomeEducationCardVariant.sideEffectsHistory,
          title: 'Efeitos\nAdversos',
          description: 'Entenda sinais importantes durante tratamento.',
          imageAsset: 'assets/images/efeitosAdversos.png',
          onTap: onTap,
        );

  final _PatientHomeEducationCardVariant _variant;
  final String title;
  final String description;
  final String? imageAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _PatientHomeEducationCardVariant.sideEffectsShortcut =>
        _SideEffectsShortcutCard(
          title: title,
          onTap: onTap,
        ),
      _PatientHomeEducationCardVariant.knowledgeBase ||
      _PatientHomeEducationCardVariant.sideEffectsHistory =>
        _EducationArticleCard(
          title: title,
          description: description,
          imageAsset: imageAsset!,
          onTap: onTap,
        ),
    };
  }
}

class _SideEffectsShortcutCard extends StatelessWidget {
  const _SideEffectsShortcutCard({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  static const _width = 145.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE3ECF7),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: _width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 90, 12, 18),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.p06,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '+',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textInverse,
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      height: 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EducationArticleCard extends StatelessWidget {
  const _EducationArticleCard({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.onTap,
  });

  final String title;
  final String description;
  final String imageAsset;
  final VoidCallback onTap;

  static const _width = 145.0;
  static const _imageHeight = 102.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: _width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(9),
                ),
                child: Image.asset(
                  imageAsset,
                  width: double.infinity,
                  height: _imageHeight,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.p05,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.03,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 0),
                child: Text(
                  description,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}