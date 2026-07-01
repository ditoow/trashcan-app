import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trashscanp_app/main.dart';

void main() {
  testWidgets('TrashScan renders permission screen when camera denied', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrashScanApp()));

    expect(find.text('Izin Kamera Diperlukan'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.camera), findsOneWidget);
    expect(find.text('Berikan Izin'), findsOneWidget);
  });
}
