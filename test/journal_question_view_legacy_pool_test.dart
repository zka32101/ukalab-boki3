import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/journal_input/account_catalog.dart';
import 'package:ukalab_boki3/journal_input/account_picker_sheet.dart';

/// [JournalQuestionView]・[JournalInputTable] に渡した `accountPool` が
/// 科目ピッカー（[showAccountPicker]）までそのまま伝わることを確認する。
/// 旧区分表（`level3_until_2027_03`）向けの手形問題は、デフォルトの
/// `boki3Accounts` には受取手形・支払手形が含まれないため、`accountPool`
/// を `boki3AccountsLegacy` に切り替えないと正解を選べない。
void main() {
  testWidgets('accountPoolにboki3AccountsLegacyを指定すると、科目ピッカーで「支払手形」を検索・選択できる', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selected = await showAccountPicker(context, pool: boki3AccountsLegacy);
              },
              child: const Text('科目を選ぶ'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('科目を選ぶ'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '支払手形');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, '支払手形'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, '支払手形'));
    await tester.pumpAndSettle();

    expect(selected, 'notes_payable');
  });
}
