part of '../welcome_page.dart';

// ── Phase 1 ───────────────────────────────────────────────────────────────────

class _Phase1Section extends StatelessWidget {
  const _Phase1Section({required this.sectionKey});

  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'ARQUITECTURA'),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '01',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fase 1 · Implementación Rápida',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Flutter consume Supabase directamente. Go recolecta vía SNMP y escribe en BD cloud.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _StatusBadge(label: 'Completada', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(flex: 5, child: _Phase1Content()),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 4,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: Image.asset(
                          AppAssets.illustrationGuardianShield,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  const _Phase1Content(),
                  const SizedBox(height: 32),
                  Image.asset(
                    AppAssets.illustrationGuardianShield,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Phase1Content extends StatelessWidget {
  const _Phase1Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _FlowStep(
                icon: Icons.lock_outlined,
                title: 'Passbolt',
                subtitle: 'SNMP :1161',
                color: AppColors.warning,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.computer_rounded,
                title: 'ChkMonitor',
                subtitle: 'SNMP :2161',
                color: AppColors.warning,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.memory_rounded,
                title: 'Go',
                subtitle: 'Recolector',
                color: AppColors.primary,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.bolt_rounded,
                title: 'Supabase',
                subtitle: 'Cloud BD',
                color: AppColors.primaryBright,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.flutter_dash_rounded,
                title: 'Flutter',
                subtitle: 'Panel Web',
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _PhaseComponent(
          color: AppColors.primary,
          title: 'Go Recolector',
          items: [
            'Consulta SNMP concurrente a ambos servicios',
            'Procesamiento y normalización de métricas',
            'Escritura directa en Supabase Cloud',
            'Reintento automático ante fallos de red',
            'Intervalo configurable de 5-10 minutos',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.primaryBright,
          title: 'Supabase Cloud',
          items: [
            'PostgreSQL como base de datos relacional',
            'Supabase Auth para autenticación de usuarios',
            'Realtime para suscripciones en tiempo real',
            'Storage para archivos y configuraciones',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.secondary,
          title: 'Flutter Panel',
          items: [
            'Consume Supabase REST + Realtime',
            'Dashboards y gráficas interactivas',
            'Multiplataforma: Android, iOS, Web, Desktop',
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Arquitectura simple y rápida de implementar. Go recolecta vía SNMP '
                  'y escribe directamente en Supabase. Flutter consume Supabase para '
                  'mostrar la información en tiempo real.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Phase 2 ───────────────────────────────────────────────────────────────────

class _Phase2Section extends StatelessWidget {
  const _Phase2Section();

  @override
  Widget build(BuildContext context) {
    return _Section(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'ARQUITECTURA'),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '02',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fase 2 · Alta Disponibilidad',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Clúster Patroni de 3 nodos con HAProxy y etcd. Node.js expone '
                      'REST + Socket.IO. Failover automático sin pérdida de escrituras.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _StatusBadge(label: 'Implementada', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              if (isWide) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _PatroniClusterDiagram()),
                    SizedBox(width: 48),
                    Expanded(flex: 5, child: _Phase2Content()),
                  ],
                );
              }
              return const Column(
                children: [
                  _Phase2Content(),
                  SizedBox(height: 32),
                  _PatroniClusterDiagram(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Phase2Content extends StatelessWidget {
  const _Phase2Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _FlowStep(
                icon: Icons.lock_outlined,
                title: 'Servicios',
                subtitle: ':1161 / :2161',
                color: AppColors.warning,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.memory_rounded,
                title: 'Go',
                subtitle: 'Recolector',
                color: AppColors.primary,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.balance_rounded,
                title: 'HAProxy',
                subtitle: 'Balanceador',
                color: AppColors.secondary,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.storage_rounded,
                title: 'Patroni',
                subtitle: '3 Nodos HA',
                color: AppColors.primaryBright,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.hub_outlined,
                title: 'Node.js',
                subtitle: 'API + Socket.IO',
                color: AppColors.primary,
              ),
              _FlowArrow(),
              _FlowStep(
                icon: Icons.flutter_dash_rounded,
                title: 'Flutter',
                subtitle: 'Panel Web',
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _PhaseComponent(
          color: AppColors.primary,
          title: 'Go Recolector',
          items: [
            'Consulta SNMP concurrente con goroutines',
            'Validación y procesamiento de métricas',
            'Escritura en primario vía HAProxy (puerto 5432)',
            'Reintentos y manejo de errores de red',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.secondary,
          title: 'HAProxy · Load Balancer',
          items: [
            'Enruta escrituras siempre al nodo primario Patroni',
            'Healthcheck cada 2 s — detecta failover automáticamente',
            'Puerto 5432 para escritura, 5433 para solo lectura',
            'Sin reconfiguración de clientes ante failover',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.primaryBright,
          title: 'PostgreSQL Patroni HA (3 nodos)',
          items: [
            'Primario + 2 réplicas con streaming replication',
            'etcd gestiona consenso y elección de líder',
            'Failover automático en < 30 s ante caída del primario',
            'WAL shipping garantiza cero pérdida de escrituras',
          ],
        ),
        const SizedBox(height: 12),
        const _PhaseComponent(
          color: AppColors.primary,
          title: 'Node.js + Socket.IO',
          items: [
            'APIs REST consumidas por Flutter',
            'pg_notify → Socket.IO para eventos en tiempo real',
            'JWT stateless — sin sesiones en servidor',
            'Emite active_alerts, db_health, collector_run',
          ],
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BenefitChip(
              label: 'Failover automático',
              icon: Icons.autorenew_rounded,
              color: AppColors.primary,
            ),
            _BenefitChip(
              label: 'Alta disponibilidad',
              icon: Icons.verified_outlined,
              color: AppColors.secondary,
            ),
            _BenefitChip(
              label: 'Tiempo real eficiente',
              icon: Icons.bolt_rounded,
              color: AppColors.primaryBright,
            ),
            _BenefitChip(
              label: 'Sin punto único de fallo',
              icon: Icons.shield_outlined,
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Builder(
          builder: (context) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Clúster Patroni de 3 nodos gestionado por etcd. HAProxy detecta el '
                    'primario activo y enruta escrituras sin reconfiguración. Node.js '
                    'escucha pg_notify y emite eventos vía Socket.IO al panel Flutter.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Patroni Cluster Diagram ───────────────────────────────────────────────────

class _PatroniClusterDiagram extends StatelessWidget {
  const _PatroniClusterDiagram();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _PatroniDiagramPainter(),
            size: Size(constraints.maxWidth, 220),
          ),
        ),
      ),
    );
  }
}

class _PatroniDiagramPainter extends CustomPainter {
  static const _sectionBg = Color(0xFF252830);
  static const _innerBg = Color(0xFF1A1D24);
  static const _labelC = Color(0xFF8A8E9A);
  static const _textC = Color(0xFFEAEAEA);
  static const _arrowC = Color(0xFFCCCCCC);
  static const _strokeC = Color(0xFF383D4A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const gap = 12.0;
    const labelAreaH = 26.0;
    const innerPad = 10.0;
    const sectionR = Radius.circular(10);
    const innerR = Radius.circular(7);

    final haW = w * 0.22;
    final ptW = w * 0.34;
    final etW = w - haW - ptW - gap * 2;

    final haX = 0.0;
    final ptX = haX + haW + gap;
    final etX = ptX + ptW + gap;

    final sectionFill = Paint()..color = _sectionBg;
    final innerFill = Paint()..color = _innerBg;
    final strokePaint = Paint()
      ..color = _strokeC
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final arrowLinePaint = Paint()
      ..color = _arrowC
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final arrowFill = Paint()..color = _arrowC;

    void drawBox(Rect rect, {Radius radius = sectionR, bool inner = false}) {
      final rr = RRect.fromRectAndRadius(rect, radius);
      canvas.drawRRect(rr, inner ? innerFill : sectionFill);
      canvas.drawRRect(rr, strokePaint);
    }

    void drawLabel(
      String text,
      Rect within, {
      bool isLabel = false,
      double fontSize = 11,
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: isLabel ? _labelC : _textC,
            fontSize: fontSize,
            fontWeight: isLabel ? FontWeight.w500 : FontWeight.w600,
            letterSpacing: isLabel ? 0.6 : 0,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout(maxWidth: within.width);
      tp.paint(
        canvas,
        Offset(
          within.left + (within.width - tp.width) / 2,
          within.top + (within.height - tp.height) / 2,
        ),
      );
    }

    // Sections
    drawBox(Rect.fromLTWH(haX, 0, haW, h));
    drawBox(Rect.fromLTWH(ptX, 0, ptW, h));
    drawBox(Rect.fromLTWH(etX, 0, etW, h));

    // Section labels
    drawLabel('HAProxy', Rect.fromLTWH(haX, 0, haW, labelAreaH), isLabel: true);
    drawLabel('Patroni', Rect.fromLTWH(ptX, 0, ptW, labelAreaH), isLabel: true);
    drawLabel('etcd', Rect.fromLTWH(etX, 0, etW, labelAreaH), isLabel: true);

    // HAProxy inner box
    const balaH = 38.0;
    final balaTop = labelAreaH + (h - labelAreaH - balaH) / 2;
    final balaRect = Rect.fromLTWH(
      haX + innerPad,
      balaTop,
      haW - innerPad * 2,
      balaH,
    );
    drawBox(balaRect, radius: innerR, inner: true);
    drawLabel('Balanceador', balaRect);

    // Patroni nodes
    final nodeAreaTop = labelAreaH + innerPad;
    final nodeAreaH = h - nodeAreaTop - innerPad;
    final nodeH = (nodeAreaH - gap * 2) / 3;
    final nodeRects = List.generate(
      3,
      (i) => Rect.fromLTWH(
        ptX + innerPad,
        nodeAreaTop + i * (nodeH + gap),
        ptW - innerPad * 2,
        nodeH,
      ),
    );
    for (var i = 0; i < 3; i++) {
      drawBox(nodeRects[i], radius: innerR, inner: true);
      drawLabel('Nodo ${i + 1}', nodeRects[i]);
    }

    // etcd inner box
    const almacenH = 52.0;
    final almacenTop = labelAreaH + (h - labelAreaH - almacenH) / 2;
    final almacenRect = Rect.fromLTWH(
      etX + innerPad,
      almacenTop,
      etW - innerPad * 2,
      almacenH,
    );
    drawBox(almacenRect, radius: innerR, inner: true);
    drawLabel('Almacén\nde estado', almacenRect, fontSize: 10.5);

    // ── Arrow helpers ────────────────────────────────────────────────────────

    void drawArrowhead(Offset tip, Offset from) {
      final dx = tip.dx - from.dx;
      final dy = tip.dy - from.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < 1) return;
      const aSize = 5.5;
      final ux = dx / dist;
      final uy = dy / dist;
      final px = -uy * 0.38;
      final py = ux * 0.38;
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          tip.dx - aSize * ux + aSize * px,
          tip.dy - aSize * uy + aSize * py,
        )
        ..lineTo(
          tip.dx - aSize * ux - aSize * px,
          tip.dy - aSize * uy - aSize * py,
        )
        ..close();
      canvas.drawPath(path, arrowFill);
    }

    void drawCurvedArrow(Offset from, Offset to, {bool bidirectional = false}) {
      final path = Path()..moveTo(from.dx, from.dy);
      if ((from.dy - to.dy).abs() > 4) {
        final mid = (from.dx + to.dx) / 2;
        path.cubicTo(mid, from.dy, mid, to.dy, to.dx, to.dy);
      } else {
        path.lineTo(to.dx, to.dy);
      }
      canvas.drawPath(path, arrowLinePaint);
      drawArrowhead(to, from);
      if (bidirectional) drawArrowhead(from, to);
    }

    // HAProxy → each Patroni node
    for (var i = 0; i < 3; i++) {
      drawCurvedArrow(
        Offset(balaRect.right, balaRect.center.dy),
        Offset(nodeRects[i].left, nodeRects[i].center.dy),
      );
    }

    // each Patroni node ↔ etcd (bidirectional)
    for (var i = 0; i < 3; i++) {
      drawCurvedArrow(
        Offset(nodeRects[i].right, nodeRects[i].center.dy),
        Offset(almacenRect.left, almacenRect.center.dy),
        bidirectional: true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Shared phase helpers ──────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FlowArrow extends StatelessWidget {
  const _FlowArrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: AppColors.primary.withValues(alpha: 0.5),
        size: 18,
      ),
    );
  }
}

class _PhaseComponent extends StatelessWidget {
  const _PhaseComponent({
    required this.color,
    required this.title,
    required this.items,
  });

  final Color color;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
