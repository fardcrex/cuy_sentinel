import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app.dart';
import 'core/env/app_env.dart';
import 'core/injection/envs/production_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
  );
  runApp(CuySentinelApp(dependencies: buildProductionDependencies()));
}
