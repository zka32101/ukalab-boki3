import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/term/term_list_page.dart';

void main() {
  testWidgets('用語集を開き、タップすると解説カードがボトムシートで開く', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: TermListPage()));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('仕訳'), findsOneWidget);

    await tester.tap(find.text('仕訳'));
    await tester.pumpAndSettle();

    expect(
      find.text('取引が起きたとき、増減する勘定科目を借方（左側）と貸方（右側）に分けて記録すること。すべての帳簿記入のもとになる。'),
      findsOneWidget,
    );
    expect(find.text('関連用語'), findsOneWidget);
  });
}
