import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env/app_env.dart';
import 'core/injection/envs/phase1_dependencies.dart';
import 'presentation/app.dart';

void main() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );
  runApp(CuySentinelApp(dependencies: buildPhase1Dependencies()));
}
