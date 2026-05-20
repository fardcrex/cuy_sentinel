import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/app.dart';
import 'core/injection/envs/demo_dependencies.dart';

void main() {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CuySentinelApp(dependencies: buildDemoDependencies()));
}
