import 'package:flutter/widgets.dart';

import 'core/app.dart';
import 'core/injection/envs/demo_dependencies.dart';

// Demo mode — no credentials needed.
// flutter run --target lib/main_development.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CuySentinelApp(dependencies: buildDemoDependencies()));
}
