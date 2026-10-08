import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/term/term_list_page.dart';

void main() {
  testWidgets('検索すると該当する用語だけに絞り込まれる', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: TermListPage()));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '貸借対照表');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, '貸借対照表'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '仕訳'), findsNothing);
  });
}
