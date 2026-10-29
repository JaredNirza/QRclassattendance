import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/main.dart';

void main() {
  testWidgets('EduTrack dashboard renders branding and navigation buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const EduTrackApp());
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Scanner'), findsOneWidget);
  });
}
