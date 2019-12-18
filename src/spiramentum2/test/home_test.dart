// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiramentum2/home.dart';
import 'package:spiramentum2/main.dart';

void main() {
  testWidgets('Initial rendering', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text("How much time do you want to spend?"),
        findsOneWidget);
    expect(find.byWidgetPredicate((Widget widget) => widget is CupertinoPicker),
        findsOneWidget);
    expect(tester.getSize(find.byWidgetPredicate((Widget widget) => widget is SizeTransition && widget.child is Center)).height, 0);
    expect(tester.getSize(find.byWidgetPredicate((Widget widget) => widget is SizeTransition && widget.child is Container)).height, 200);
    expect(find.byIcon(CupertinoIcons.play_arrow_solid), findsOneWidget);
  });

  testWidgets('Timer tests', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    MyHomePageState state = tester.state(find.byType(MyHomePage));
    expect(state.isTimerRunning, false);
    await tester.tap(find.byIcon(CupertinoIcons.play_arrow_solid));
    expect(state.isTimerRunning, true);
  });
}
