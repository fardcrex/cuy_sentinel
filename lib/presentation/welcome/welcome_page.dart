import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/assets/app_assets.dart';
import '../../core/navigation/app_router.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/brand_asset_icon.dart';
import '../widgets/matrix_background.dart';

part 'widges/footer_section.dart';
part 'widges/hero_section.dart';
part 'widges/nav_section.dart';
part 'widges/objectives_section.dart';
part 'widges/phases_section.dart';
part 'widges/platforms_section.dart';
part 'widges/professor_services_section.dart';
part 'widges/shared_section.dart';
part 'widges/team_section.dart';
part 'widges/tech_stack_section.dart';

const double _kContentMaxWidth = 1280.0;

// ─── Screen ───────────────────────────────────────────────────────────────────

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  final _teamKey = GlobalKey();
  final _servicesKey = GlobalKey();
  final _etapaKey = GlobalKey();
  final _archKey = GlobalKey();
  final _platformsKey = GlobalKey();
  final _techKey = GlobalKey();

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (_, _) => CustomPaint(
                  painter: MatrixBackgroundPainter(
                    progress: _bgController.value,
                    density: 0.8,
                    toneColor: AppColors.primary,
                    accentToneColor: AppColors.primaryBright,
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                _NavBar(
                  onTeam: () => _scrollTo(_teamKey),
                  onEtapa: () => _scrollTo(_etapaKey),
                  onArch: () => _scrollTo(_archKey),
                  onPlatforms: () => _scrollTo(_platformsKey),
                  onTech: () => _scrollTo(_techKey),
                ),
                const _HeroSection(),
                _TeamSection(sectionKey: _teamKey),
                const _ProfessorSection(),
                _ServicesSection(sectionKey: _servicesKey),
                _EtapaObjectivesSection(sectionKey: _etapaKey),
                _Phase1Section(sectionKey: _archKey),
                const _Phase2Section(),
                _PlatformsSection(sectionKey: _platformsKey),
                _TechStackSection(sectionKey: _techKey),
                const _FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
