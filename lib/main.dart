import 'package:flutter/widgets.dart';

import 'core/app.dart';
import 'core/injection/envs/demo_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CuySentinelApp(dependencies: buildDemoDependencies()));
}
