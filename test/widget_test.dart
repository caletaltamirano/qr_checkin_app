import 'package:flutter_test/flutter_test.dart';

import 'package:qr_checkin_app/main.dart';

void main() {
  testWidgets('shows the Firebase-not-configured screen when Firebase init fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(firebaseReady: false));

    expect(find.textContaining('Firebase no está configurado'), findsOneWidget);
  });
}
