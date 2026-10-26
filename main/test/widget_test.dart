// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gitinspo/main.dart';
import 'package:gitinspo/providers/app_state.dart';

void main() {
  testWidgets('GitInspo opens the home feed and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const GitInspoApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Explore as a guest'), findsOneWidget);
    await tester.ensureVisible(find.text('Explore as a guest'));
    await tester.tap(find.text('Explore as a guest'));
    await tester.pumpAndSettle();

    expect(find.text('GitInspo'), findsOneWidget);
    expect(find.text('Made for your mood'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });
}
