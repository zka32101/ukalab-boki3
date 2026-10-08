import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/term/term_list_page.dart';

void main() {
  testWidgets('科目を指定して開くと、その科目の未習得の用語だけに絞られ、解除すると全件に戻る', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        home: TermListPage(initialSubjectId: 'q1_shiwake', initialSubjectLabel: '第1問 仕訳'),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, '仕訳'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '精算表'), findsNothing);

    await tester.tap(find.textContaining('で絞り込み中'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, '精算表'), findsOneWidget);
  });
}
