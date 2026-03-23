import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/controller/app_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FreeTypeApp(controller: AppController()..initialize()));
}
