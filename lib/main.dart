import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app.dart';
import 'core/env/app_env.dart';
import 'core/injection/envs/phase1_dependencies.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );
  runApp(CuySentinelApp(dependencies: buildPhase1Dependencies()));
}
