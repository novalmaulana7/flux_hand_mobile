import 'package:flutter/material.dart';

import 'apps/app.dart';
import 'core/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const BlurWaveApp());
}
