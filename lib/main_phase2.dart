import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app.dart';
import 'core/env/app_env.dart';
import 'core/injection/envs/phase2_dependencies.dart';

// Fase 2 — Node.js API + Socket.IO.
// flutter run --target lib/main_phase2.dart \
//             --dart-define-from-file=envs/sentinel.phase2.json
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );
  runApp(CuySentinelApp(dependencies: buildPhase2Dependencies()));
}
