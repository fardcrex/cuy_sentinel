part of '../welcome_screen.dart';

class _TechStackSection extends StatelessWidget {
  const _TechStackSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _stack = [
    _TechData(
      name: 'Flutter',
      icon: Icons.flutter_dash_rounded,
      color: AppColors.secondary,
      why:
          'Panel multiplataforma desde un único codebase. Compila nativamente a iOS, Android, Web y Desktop con alto rendimiento.',
    ),
    _TechData(
      name: 'Go',
      icon: Icons.memory_rounded,
      color: AppColors.primary,
      why:
          'Concurrencia nativa con goroutines, ideal para recolección SNMP periódica y manejo paralelo de múltiples servicios.',
    ),
    _TechData(
      name: 'Supabase',
      icon: Icons.bolt_rounded,
      color: AppColors.primaryBright,
      why:
          'Plataforma BaaS que provee PostgreSQL, Auth, Realtime y Storage sin necesidad de gestionar infraestructura en Fase 1.',
    ),
    _TechData(
      name: 'PostgreSQL',
      icon: Icons.storage_rounded,
      color: AppColors.secondary,
      why:
          'BD relacional robusta con réplica asíncrona Streaming/WAL. Soporta alta disponibilidad y escalabilidad de lectura en Fase 2.',
    ),
    _TechData(
      name: 'Node.js + Socket.IO',
      icon: Icons.hub_outlined,
      color: AppColors.primaryBright,
      why:
          'API REST desacoplada para Fase 2. Socket.IO permite eventos en tiempo real sin polling, reduciendo latencia en el panel.',
    ),
    _TechData(
      name: 'Ubuntu 24.04 LTS',
      icon: Icons.computer_rounded,
      color: AppColors.warning,
      why:
          'Sistema operativo de despliegue con soporte extendido hasta 2029. Estabilidad comprobada para dockerización de servicios críticos.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Section(
      sectionKey: sectionKey,
      color: AppColors.background,
      child: Column(
        children: [
          const _SectionLabel(label: 'TECNOLOGÍAS'),
          const SizedBox(height: 12),
          Text(
            'Stack moderno de extremo a extremo',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Cada herramienta elegida por una razón específica',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900
                  ? 3
                  : constraints.maxWidth >= 600
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 300,
                ),
                itemCount: _stack.length,
                itemBuilder: (_, index) => _TechCard(tech: _stack[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TechData {
  const _TechData({
    required this.name,
    required this.icon,
    required this.color,
    required this.why,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String why;
}

class _TechCard extends StatelessWidget {
  const _TechCard({required this.tech});

  final _TechData tech;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: tech.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tech.color.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: tech.color.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: Icon(tech.icon, size: 52, color: tech.color)),
          ),
          const SizedBox(height: 16),
          Text(
            tech.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            tech.why,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
