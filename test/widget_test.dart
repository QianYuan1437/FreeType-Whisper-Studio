import 'package:flutter_test/flutter_test.dart';

import 'package:freetype/src/app.dart';
import 'package:freetype/src/controller/app_controller.dart';

void main() {
  testWidgets('App boots and shows FreeType shell', (WidgetTester tester) async {
    final controller = AppController()
      ..isReady = true
      ..status = 'Ready';
    await tester.pumpWidget(FreeTypeApp(controller: controller));
    await tester.pump();

    expect(find.textContaining('FreeType'), findsWidgets);
  });
}
