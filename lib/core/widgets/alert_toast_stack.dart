import 'package:flutter/material.dart';

import '../../feature/alerts/domain/entities/alert_event.dart';
import '../../feature/alerts/domain/entities/alert_severity.dart';
import '../theme/app_colors.dart';

const _nuclearToastColor = Color(0xFFFF0040);

// ─── Public API ───────────────────────────────────────────────────────────────

abstract final class AlertToastStack {
  static OverlayEntry? _entry;
  static final _items = ValueNotifier<List<_ToastItem>>([]);

  static void add(OverlayState overlay, AlertEvent event) {
    _items.value = [..._items.value, _ToastItem(event: event)];
    if (_entry == null) {
      _entry = OverlayEntry(
        builder: (_) =>
            _AlertToastStackWidget(items: _items, onRemove: _remove),
      );
      overlay.insert(_entry!);
    }
  }

  static void _remove(_ToastItem item) {
    final updated = _items.value.where((i) => i != item).toList();
    _items.value = updated;
    if (updated.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _entry?.remove();
        _entry = null;
      });
    }
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class _ToastItem {
  _ToastItem({required this.event});
  final AlertEvent event;
}

// ─── Overlay widget ───────────────────────────────────────────────────────────

class _AlertToastStackWidget extends StatelessWidget {
  const _AlertToastStackWidget({required this.items, required this.onRemove});

  final ValueNotifier<List<_ToastItem>> items;
  final void Function(_ToastItem) onRemove;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_ToastItem>>(
      valueListenable: items,
      builder: (context, toasts, _) {
        if (toasts.isEmpty) return const SizedBox.shrink();

        final screen = MediaQuery.of(context).size;
        final isMobile = screen.width < 600;
        final top =
            MediaQuery.of(context).viewPadding.top + (isMobile ? 56 : 16);
        final right = isMobile ? 8.0 : 20.0;
        final width = isMobile ? screen.width - 32 : 340.0;

        return Positioned(
          top: top,
          right: right,
          width: width,
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < toasts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _AlertToastCard(
                    key: ObjectKey(toasts[i]),
                    item: toasts[i],
                    onDismiss: () => onRemove(toasts[i]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Toast card ───────────────────────────────────────────────────────────────

class _AlertToastCard extends StatefulWidget {
  const _AlertToastCard({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  final _ToastItem item;
  final VoidCallback onDismiss;

  @override
  State<_AlertToastCard> createState() => _AlertToastCardState();
}

class _AlertToastCardState extends State<_AlertToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.18, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _accent => switch (widget.item.event.severity) {
    AlertSeverity.nuclear => _nuclearToastColor,
    AlertSeverity.critical => AppColors.danger,
    AlertSeverity.warning => AppColors.warning,
    AlertSeverity.info => AppColors.primary,
  };

  IconData get _icon => switch (widget.item.event.severity) {
    AlertSeverity.nuclear => Icons.crisis_alert_rounded,
    AlertSeverity.critical => Icons.error_rounded,
    AlertSeverity.warning => Icons.warning_amber_rounded,
    AlertSeverity.info => Icons.info_outline_rounded,
  };

  String get _label => switch (widget.item.event.severity) {
    AlertSeverity.nuclear => 'NUCLEAR',
    AlertSeverity.critical => 'Crítico',
    AlertSeverity.warning => 'Advertencia',
    AlertSeverity.info => 'Info',
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final event = widget.item.event;

    return Dismissible(
      key: ValueKey(widget.item),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => widget.onDismiss(),
      background: const _DismissBackground(),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.stroke),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 3, color: accent),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(_icon, color: accent, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: accent,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    event.serviceName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    event.metricName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: widget.onDismiss,
                              icon: const Icon(Icons.close_rounded),
                              color: AppColors.textSecondary,
                              iconSize: 16,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Cerrar alerta',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: const Icon(
        Icons.check_rounded,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}
