import 'package:flutter/widgets.dart';

import 'core/app.dart';
import 'core/injection/envs/development_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CuySentinelApp(dependencies: buildDevelopmentDependencies()));
}
