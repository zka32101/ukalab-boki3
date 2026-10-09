import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/journal_input/account_picker_sheet.dart';

/// `accountPool` を指定しない（新区分表のデフォルト `boki3Accounts`）場合、
/// 2027年4月以降は出題されない受取手形・支払手形が選択肢に出ないことを確認する。
void main() {
  testWidgets('accountPoolを指定しない場合、支払手形は科目ピッカーの検索結果に出ない', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAccountPicker(context),
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
    expect(find.widgetWithText(ListTile, '支払手形'), findsNothing);
  });
}
