import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/term/term_list_page.dart';

void main() {
  testWidgets('「覚えた」にチェックすると、「未習得」フィルタで一覧から消える', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: TermListPage()));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, '仕訳'), findsOneWidget);

    await tester.tap(
      find.descendant(of: find.widgetWithText(ListTile, '仕訳'), matching: find.byType(Checkbox)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('未習得'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, '仕訳'), findsNothing);
    expect(find.widgetWithText(ListTile, '複式簿記'), findsOneWidget);

    await tester.tap(find.text('覚えた'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, '仕訳'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '複式簿記'), findsNothing);
  });
}
