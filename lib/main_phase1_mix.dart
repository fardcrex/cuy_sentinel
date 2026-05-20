import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app.dart';
import 'core/env/app_env.dart';
import 'core/injection/envs/phase1_dependencies.dart';

// Fase 1 — Supabase.
// flutter run --target lib/main_production.dart \
//             --dart-define-from-file=envs/sentinel.phase1.json
void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );
  runApp(CuySentinelApp(dependencies: buildPhase1DependenciesMix()));
}
