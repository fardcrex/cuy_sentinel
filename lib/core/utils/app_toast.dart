import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ─── Public API ───────────────────────────────────────────────────────────────

abstract final class AppToast {
  static OverlayEntry? _entry;

  static void success(BuildContext context, String message, {String? detail}) =>
      _show(
        context,
        message: message,
        detail: detail,
        type: _ToastType.success,
      );

  static void error(BuildContext context, String message, {String? detail}) =>
      _show(context, message: message, detail: detail, type: _ToastType.error);

  static void warning(BuildContext context, String message, {String? detail}) =>
      _show(
        context,
        message: message,
        detail: detail,
        type: _ToastType.warning,
      );

  static void _show(
    BuildContext context, {
    required String message,
    required _ToastType type,
    String? detail,
  }) {
    _entry?.remove();
    _entry = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        message: message,
        detail: detail,
        type: type,
        onDone: () {
          entry.remove();
          if (_entry == entry) _entry = null;
        },
      ),
    );

    _entry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }
}

// ─── Types ────────────────────────────────────────────────────────────────────

enum _ToastType { success, error, warning }

// ─── Overlay widget ───────────────────────────────────────────────────────────

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.onDone,
    this.detail,
  });

  final String message;
  final String? detail;
  final _ToastType type;
  final VoidCallback onDone;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  static const _enterDuration = Duration(milliseconds: 300);
  static const _exitDuration = Duration(milliseconds: 200);

  Duration get _visibleDuration => widget.type == _ToastType.error
      ? const Duration(seconds: 5)
      : const Duration(milliseconds: 2800);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _enterDuration);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
    Future.delayed(_visibleDuration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    _ctrl.duration = _exitDuration;
    await _ctrl.reverse();
    if (mounted) widget.onDone();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final card = Dismissible(
      key: ValueKey('${widget.type}-${widget.message}-${widget.detail ?? ''}'),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => _dismiss(),
      background: const _ToastDismissBackground(),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: _ToastCard(
            message: widget.message,
            detail: widget.detail,
            type: widget.type,
            onClose: _dismiss,
          ),
        ),
      ),
    );

    if (isMobile) {
      return Positioned(
        top: MediaQuery.of(context).viewPadding.top + 48,
        left: 16,
        right: 16,
        child: card,
      );
    }

    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 16,
      right: 20,
      width: 340,
      child: card,
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.message,
    required this.type,
    required this.onClose,
    this.detail,
  });

  final String message;
  final String? detail;
  final _ToastType type;
  final VoidCallback onClose;

  static const _bg = AppColors.surface;
  static const _border = AppColors.stroke;
  static const _textPrimary = AppColors.textPrimary;
  static const _textSecondary = AppColors.textSecondary;

  Color get _accentColor => switch (type) {
    _ToastType.success => AppColors.primary,
    _ToastType.error => AppColors.danger,
    _ToastType.warning => AppColors.warning,
  };

  IconData get _icon => switch (type) {
    _ToastType.success => Icons.check_circle_rounded,
    _ToastType.error => Icons.error_rounded,
    _ToastType.warning => Icons.warning_amber_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar
                  Container(width: 3, color: accent),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(_icon, color: accent, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  message,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                                if (detail != null) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    detail!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            onPressed: onClose,
                            icon: const Icon(Icons.close_rounded),
                            color: _textSecondary,
                            iconSize: 16,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Cerrar notificación',
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
    );
  }
}

class _ToastDismissBackground extends StatelessWidget {
  const _ToastDismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
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
