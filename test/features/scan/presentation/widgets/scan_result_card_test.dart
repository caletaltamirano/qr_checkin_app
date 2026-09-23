import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/scan_result.dart';
import 'package:qr_checkin_app/features/scan/domain/entities/ticket.dart';
import 'package:qr_checkin_app/features/scan/presentation/widgets/scan_result_card.dart';

void main() {
  final result = ScanResult(
    type: ScanResultType.valid,
    message: 'Ticket válido',
    holderName: 'Jane Doe',
    ticketType: TicketType.vip,
    usedAt: DateTime(2026, 9, 20, 21, 5),
  );

  Future<void> pumpCard(WidgetTester tester, VoidCallback onDismissed) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Stack(children: [ScanResultCard(result: result, onDismissed: onDismissed)]),
      ),
    ));
  }

  /// Advances time frame by frame (16ms), like a real device would, so
  /// animations started mid-way actually get ticked to completion.
  Future<void> pumpFor(WidgetTester tester, Duration total) async {
    const frame = Duration(milliseconds: 16);
    for (var elapsed = Duration.zero; elapsed < total; elapsed += frame) {
      await tester.pump(frame);
    }
  }

  testWidgets('shows the holder name, ticket type and check-in time', (tester) async {
    await pumpCard(tester, () {});
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('Ingresó a las 21:05'), findsOneWidget);
    expect(find.text('ENTRADA VÁLIDA'), findsOneWidget);
  });

  testWidgets('dismisses itself after the auto-dismiss delay', (tester) async {
    var dismissed = 0;
    await pumpCard(tester, () => dismissed++);

    await tester.pump(ScanResultCard.autoDismissAfter - const Duration(milliseconds: 100));
    expect(dismissed, 0);

    await tester.pumpAndSettle();
    expect(dismissed, 1);
  });

  testWidgets('dismisses early when tapped', (tester) async {
    var dismissed = 0;
    await pumpCard(tester, () => dismissed++);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Jane Doe'));
    await pumpFor(tester, const Duration(milliseconds: 400));

    expect(dismissed, 1);
  });

  testWidgets('dismisses when swiped down', (tester) async {
    var dismissed = 0;
    await pumpCard(tester, () => dismissed++);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.fling(find.text('Jane Doe'), const Offset(0, 200), 1000);
    await pumpFor(tester, const Duration(milliseconds: 600));

    expect(dismissed, 1);
  });

  testWidgets('a small drag snaps back instead of dismissing', (tester) async {
    var dismissed = 0;
    await pumpCard(tester, () => dismissed++);
    await tester.pump(const Duration(milliseconds: 300));

    final gesture = await tester.startGesture(tester.getCenter(find.text('Jane Doe')));
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.moveBy(const Offset(0, 1));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await pumpFor(tester, const Duration(milliseconds: 600));

    expect(dismissed, 0);
  });
}
