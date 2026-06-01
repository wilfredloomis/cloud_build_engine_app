import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_build_engine_app/app/app.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    await tester.pumpWidget(const CloudBuildApp());
    expect(find.text('Cloud Build Engine'), findsOneWidget);
  });
}
