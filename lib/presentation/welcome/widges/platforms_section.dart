part of '../welcome_page.dart';

enum _DeviceType { phone, tablet, laptop, desktop }

class _PlatformsSection extends StatelessWidget {
  const _PlatformsSection({required this.sectionKey});

  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.panel,
      child: Column(
        children: [
          const _SectionLabel(label: 'MULTIPLATAFORMA'),
          const SizedBox(height: 12),
          Text(
            'Disponible en todos los dispositivos',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Un único codebase Flutter compilado nativamente para cada plataforma',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 56),
          const Wrap(
            spacing: 48,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _DeviceShowcase(
                type: _DeviceType.phone,
                label: 'Smartphone',
                platforms: 'iOS · Android',
              ),
              _DeviceShowcase(
                type: _DeviceType.tablet,
                label: 'Tablet',
                platforms: 'iPad · Android',
              ),
              _DeviceShowcase(
                type: _DeviceType.laptop,
                label: 'Laptop',
                platforms: 'macOS · Windows',
              ),
              _DeviceShowcase(
                type: _DeviceType.desktop,
                label: 'Escritorio / Web',
                platforms: 'Browser · Desktop',
              ),
            ],
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.tealGlow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flutter_dash_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Flutter — un codebase, infinitas plataformas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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

class _DeviceShowcase extends StatelessWidget {
  const _DeviceShowcase({
    required this.type,
    required this.label,
    required this.platforms,
  });

  final _DeviceType type;
  final String label;
  final String platforms;

  @override
  Widget build(BuildContext context) {
    final isWide = type == _DeviceType.laptop || type == _DeviceType.desktop;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: isWide ? 160 : 130,
          height: 148,
          child: CustomPaint(painter: _DevicePainter(type)),
        ),
        const SizedBox(height: 14),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          platforms,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _DevicePainter extends CustomPainter {
  const _DevicePainter(this.type);

  final _DeviceType type;

  Paint _fill(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  Paint _stroke(Color color, [double width = 0.8]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width;

  RRect _rr(Rect rect, [double radius = 2.5]) =>
      RRect.fromRectAndRadius(rect, Radius.circular(radius));

  void _card(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    Color accent,
  ) {
    canvas.drawRRect(
      _rr(Rect.fromLTWH(x, y, w, h), 2),
      _fill(AppColors.surface),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(x, y, w, h), 2),
      _stroke(AppColors.stroke, 0.4),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(x, y, 2, h), 1),
      _fill(accent.withValues(alpha: 0.8)),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(x + 5, y + 2.5, w * 0.45, 2), 1),
      _fill(accent.withValues(alpha: 0.6)),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(x + 5, y + 6.5, w * 0.3, 1.5), 1),
      _fill(AppColors.textInactive.withValues(alpha: 0.35)),
    );
  }

  void _header(Canvas canvas, Rect screen, double height) {
    canvas.drawRect(
      Rect.fromLTWH(screen.left, screen.top, screen.width, height),
      _fill(AppColors.panel),
    );
    canvas.drawLine(
      Offset(screen.left, screen.top + height),
      Offset(screen.right, screen.top + height),
      _stroke(AppColors.primary.withValues(alpha: 0.3), 0.5),
    );
    canvas.drawCircle(
      Offset(screen.left + 5, screen.top + height / 2),
      2,
      _fill(AppColors.primary.withValues(alpha: 0.85)),
    );
  }

  void _sidebar(Canvas canvas, Rect screen, double width) {
    canvas.drawRect(
      Rect.fromLTWH(screen.left, screen.top, width, screen.height),
      _fill(AppColors.panel),
    );
    canvas.drawLine(
      Offset(screen.left + width, screen.top),
      Offset(screen.left + width, screen.bottom),
      _stroke(AppColors.stroke, 0.4),
    );
    for (var index = 0; index < 4; index++) {
      final y = screen.top + 14 + index * 9.0;
      if (index == 0) {
        canvas.drawRRect(
          _rr(Rect.fromLTWH(screen.left + 2, y - 1, width - 4, 7), 2),
          _fill(AppColors.primary.withValues(alpha: 0.18)),
        );
      }
      canvas.drawRRect(
        _rr(Rect.fromLTWH(screen.left + 4, y + 1, width - 10, 3), 1),
        _fill(
          (index == 0 ? AppColors.primary : AppColors.textInactive).withValues(
            alpha: index == 0 ? 0.6 : 0.22,
          ),
        ),
      );
    }
  }

  void _bottomNav(Canvas canvas, Rect screen, int count) {
    const height = 10.0;
    canvas.drawRect(
      Rect.fromLTWH(screen.left, screen.bottom - height, screen.width, height),
      _fill(AppColors.panel),
    );
    canvas.drawLine(
      Offset(screen.left, screen.bottom - height),
      Offset(screen.right, screen.bottom - height),
      _stroke(AppColors.stroke, 0.4),
    );
    final spacing = screen.width / count;
    for (var index = 0; index < count; index++) {
      final x = screen.left + spacing * index + spacing / 2;
      canvas.drawCircle(
        Offset(x, screen.bottom - height / 2),
        2,
        _fill(
          index == 0
              ? AppColors.primary.withValues(alpha: 0.9)
              : AppColors.textInactive.withValues(alpha: 0.3),
        ),
      );
    }
  }

  void _chart(Canvas canvas, Rect area) {
    canvas.drawRRect(_rr(area, 2), _fill(AppColors.surface));
    canvas.drawRRect(_rr(area, 2), _stroke(AppColors.stroke, 0.4));
    final colors = [
      AppColors.primary,
      AppColors.primaryBright,
      AppColors.primary,
      AppColors.secondary,
      AppColors.primaryBright,
      AppColors.primary,
    ];
    final barWidth = (area.width - 6) / colors.length;
    for (var index = 0; index < colors.length; index++) {
      final barHeight = 2.5 + (index % 3) * 2.5;
      canvas.drawRRect(
        _rr(
          Rect.fromLTWH(
            area.left + 3 + index * (barWidth + 0.5),
            area.bottom - 3 - barHeight,
            barWidth,
            barHeight,
          ),
          1,
        ),
        _fill(colors[index].withValues(alpha: 0.65)),
      );
    }
  }

  void _statusRow(Canvas canvas, double x, double y, double w, int count) {
    final chipWidth = (w - (count - 1) * 2) / count;
    for (var index = 0; index < count; index++) {
      final chipX = x + index * (chipWidth + 2);
      canvas.drawRRect(
        _rr(Rect.fromLTWH(chipX, y, chipWidth, 6), 2),
        _fill(AppColors.tealGlow),
      );
      canvas.drawCircle(
        Offset(chipX + 4, y + 3),
        1.5,
        _fill(AppColors.primary.withValues(alpha: 0.8)),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case _DeviceType.phone:
        _drawPhone(canvas, size);
      case _DeviceType.tablet:
        _drawTablet(canvas, size);
      case _DeviceType.laptop:
        _drawLaptop(canvas, size);
      case _DeviceType.desktop:
        _drawDesktop(canvas, size);
    }
  }

  void _drawPhone(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 2;
    canvas.drawRRect(
      _rr(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 56,
          height: 104,
        ),
        13,
      ),
      _fill(AppColors.surface),
    );
    canvas.drawRRect(
      _rr(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 56,
          height: 104,
        ),
        13,
      ),
      _stroke(AppColors.primary.withValues(alpha: 0.6), 1.5),
    );
    final screen = Rect.fromCenter(
      center: Offset(centerX, centerY - 1),
      width: 48,
      height: 88,
    );
    canvas.drawRRect(_rr(screen, 6), _fill(AppColors.background));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, screen.top + 3),
        width: 10,
        height: 4,
      ),
      _fill(AppColors.primary.withValues(alpha: 0.4)),
    );
    _header(canvas, screen, 9);
    final cardWidth = (screen.width - 5) / 2;
    const cardHeight = 13.0;
    final cardColors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.secondary,
      AppColors.primaryBright,
    ];
    for (var row = 0; row < 2; row++) {
      for (var column = 0; column < 2; column++) {
        _card(
          canvas,
          screen.left + 1 + column * (cardWidth + 2),
          screen.top + 11 + row * (cardHeight + 3),
          cardWidth,
          cardHeight,
          cardColors[row * 2 + column],
        );
      }
    }
    _statusRow(
      canvas,
      screen.left + 1,
      screen.top + 11 + 2 * (cardHeight + 3) + 2,
      screen.width - 2,
      2,
    );
    _bottomNav(canvas, screen, 4);
    canvas.drawRRect(
      _rr(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 50),
          width: 18,
          height: 3,
        ),
        2,
      ),
      _fill(AppColors.primary.withValues(alpha: 0.35)),
    );
  }

  void _drawTablet(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 2;
    canvas.drawRRect(
      _rr(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 84,
          height: 104,
        ),
        10,
      ),
      _fill(AppColors.surface),
    );
    canvas.drawRRect(
      _rr(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 84,
          height: 104,
        ),
        10,
      ),
      _stroke(AppColors.primary.withValues(alpha: 0.6), 1.5),
    );
    final screen = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: 74,
      height: 92,
    );
    canvas.drawRRect(_rr(screen, 4), _fill(AppColors.background));
    canvas.drawCircle(
      Offset(centerX, screen.top - 5),
      2.5,
      _fill(AppColors.primary.withValues(alpha: 0.35)),
    );
    _sidebar(canvas, screen, 16);
    final content = Rect.fromLTRB(
      screen.left + 16,
      screen.top,
      screen.right,
      screen.bottom,
    );
    _header(canvas, content, 9);
    final cardWidth = (content.width - 5) / 2;
    const cardHeight = 15.0;
    final cardColors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.secondary,
      AppColors.primaryBright,
    ];
    for (var row = 0; row < 2; row++) {
      for (var column = 0; column < 2; column++) {
        _card(
          canvas,
          content.left + 1 + column * (cardWidth + 2),
          content.top + 11 + row * (cardHeight + 3),
          cardWidth,
          cardHeight,
          cardColors[row * 2 + column],
        );
      }
    }
    _statusRow(
      canvas,
      content.left + 1,
      content.top + 11 + 2 * (cardHeight + 3) + 2,
      content.width - 2,
      2,
    );
  }

  void _drawLaptop(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    canvas.drawRRect(
      _rr(Rect.fromLTWH(centerX - 58, 4, 116, 74), 5),
      _fill(AppColors.surface),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(centerX - 58, 4, 116, 74), 5),
      _stroke(AppColors.primary.withValues(alpha: 0.6), 1.5),
    );
    final screen = Rect.fromLTWH(centerX - 53, 8, 106, 66);
    canvas.drawRRect(_rr(screen, 3), _fill(AppColors.background));
    canvas.drawCircle(
      Offset(centerX, 7),
      2,
      _fill(AppColors.primary.withValues(alpha: 0.35)),
    );
    _sidebar(canvas, screen, 20);
    final content = Rect.fromLTRB(
      screen.left + 20,
      screen.top,
      screen.right,
      screen.bottom,
    );
    _header(canvas, content, 8);
    final cardWidth = (content.width - 8) / 3;
    final cardColors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.secondary,
    ];
    for (var column = 0; column < 3; column++) {
      _card(
        canvas,
        content.left + 2 + column * (cardWidth + 2),
        content.top + 11,
        cardWidth,
        14,
        cardColors[column],
      );
    }
    _chart(
      canvas,
      Rect.fromLTWH(content.left + 2, content.top + 29, content.width - 4, 16),
    );
    _statusRow(
      canvas,
      content.left + 2,
      content.top + 49,
      content.width - 4,
      3,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 63, 78, 126, 4),
      _fill(AppColors.surface),
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 63, 78, 126, 4),
      _stroke(AppColors.primary.withValues(alpha: 0.5), 1.5),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(centerX - 64, 82, 128, 22), 3),
      _fill(AppColors.surface),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(centerX - 64, 82, 128, 22), 3),
      _stroke(AppColors.primary.withValues(alpha: 0.5), 1.5),
    );
    final keyPaint = _fill(AppColors.primary.withValues(alpha: 0.14));
    for (var row = 0; row < 2; row++) {
      for (var column = 0; column < 6; column++) {
        canvas.drawRRect(
          _rr(
            Rect.fromLTWH(centerX - 50 + column * 17.0, 86 + row * 7.0, 13, 4),
            1,
          ),
          keyPaint,
        );
      }
    }
  }

  void _drawDesktop(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    canvas.drawRRect(
      _rr(Rect.fromLTWH(centerX - 58, 2, 116, 78), 5),
      _fill(AppColors.surface),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(centerX - 58, 2, 116, 78), 5),
      _stroke(AppColors.primary.withValues(alpha: 0.6), 1.5),
    );
    final screen = Rect.fromLTWH(centerX - 53, 6, 106, 70);
    canvas.drawRRect(_rr(screen, 3), _fill(AppColors.background));
    _sidebar(canvas, screen, 24);
    final content = Rect.fromLTRB(
      screen.left + 24,
      screen.top,
      screen.right,
      screen.bottom,
    );
    _header(canvas, content, 8);
    final cardWidth = (content.width - 8) / 3;
    final cardColors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.secondary,
    ];
    for (var column = 0; column < 3; column++) {
      _card(
        canvas,
        content.left + 2 + column * (cardWidth + 2),
        content.top + 11,
        cardWidth,
        14,
        cardColors[column],
      );
    }
    _chart(
      canvas,
      Rect.fromLTWH(content.left + 2, content.top + 29, content.width - 4, 18),
    );
    _statusRow(
      canvas,
      content.left + 2,
      content.top + 51,
      content.width - 4,
      3,
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 5, 80, 10, 20),
      _fill(AppColors.surface),
    );
    canvas.drawRect(
      Rect.fromLTWH(centerX - 5, 80, 10, 20),
      _stroke(AppColors.primary.withValues(alpha: 0.5), 1.5),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(centerX - 30, 100, 60, 10), 5),
      _fill(AppColors.surface),
    );
    canvas.drawRRect(
      _rr(Rect.fromLTWH(centerX - 30, 100, 60, 10), 5),
      _stroke(AppColors.primary.withValues(alpha: 0.5), 1.5),
    );
  }

  @override
  bool shouldRepaint(covariant _DevicePainter oldDelegate) =>
      oldDelegate.type != type;
}
