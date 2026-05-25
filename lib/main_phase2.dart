import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/injection/envs/phase2_dependencies.dart';
import 'feature/auth/infrastructure/node_auth_repository.dart';
import 'presentation/app.dart';

// Fase 2 — Node.js API + Socket.IO.
// flutter run --target lib/main_phase2.dart \
//             --dart-define-from-file=envs/sentinel.phase2.json
void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  /*  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  ); */
  // Restore JWT from disk so currentSession() is non-null after cold start.
  await NodeAuthRepository.restoreSession();
  runApp(CuySentinelApp(dependencies: buildPhase2Dependencies()));
}

  /* 
  master@cuy.local	sentinel2025	master
  admin@cuy.local	admin2025	admin
  viewer@cuy.local	viewer2025	viewer  
   */