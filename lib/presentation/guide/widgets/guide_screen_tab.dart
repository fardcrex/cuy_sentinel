import 'package:flutter/material.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_card.dart';

class GuideCardData {
  const GuideCardData({
    required this.icon,
    required this.name,
    required this.body,
    this.illustration,
  });

  final IconData icon;
  final String name;
  final String body;
  final Widget? illustration;
}

class GuideScreenTab extends StatelessWidget {
  const GuideScreenTab({
    super.key,
    required this.title,
    required this.description,
    required this.cards,
    this.screenPreview,
  });

  final String title;
  final String description;
  final List<GuideCardData> cards;
  final Widget? screenPreview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = AppBreakpoints.horizontalPadding(width);
        final columns = width >= 900 ? 2 : 1;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (screenPreview != null) ...[
                _ScreenPreviewBanner(child: screenPreview!),
                const SizedBox(height: 24),
              ],
              _CardGrid(cards: cards, columns: columns),
            ],
          ),
        );
      },
    );
  }
}

class _CardGrid extends StatelessWidget {
  const _CardGrid({required this.cards, required this.columns});

  final List<GuideCardData> cards;
  final int columns;

  @override
  Widget build(BuildContext context) {
    if (columns == 1) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _GuideScreenCard(data: cards[i]),
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _GuideScreenCard(data: cards[i])),
            const SizedBox(width: 16),
            Expanded(
              child: i + 1 < cards.length
                  ? _GuideScreenCard(data: cards[i + 1])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < cards.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

class _ScreenPreviewBanner extends StatelessWidget {
  const _ScreenPreviewBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vista general',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.stroke),
            ),
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _GuideScreenCard extends StatelessWidget {
  const _GuideScreenCard({required this.data});

  final GuideCardData data;

  @override
  Widget build(BuildContext context) {
    final textContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(data.icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Divider(color: AppColors.stroke, height: 1),
              const SizedBox(height: 8),
              Text(
                data.body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (data.illustration == null) {
      return AppCard(child: textContent);
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Center(child: data.illustration),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: textContent,
          ),
        ],
      ),
    );
  }
}
