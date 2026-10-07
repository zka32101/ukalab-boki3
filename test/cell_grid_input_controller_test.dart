import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'package:ukalab_boki3/ledger_input/ledger_input_controller.dart';

/// `CellGridInputController`（`lib/cell_grid_input/`、`LedgerInputController`・
/// `WorksheetInputController`の共通基底）のロジックを、`LedgerInputController`
/// 経由で検証する。
void main() {
  late ProviderContainer container;
  const cellA = (0, LedgerColumnGroup.balance, LedgerField.amount);
  const cellB = (1, LedgerColumnGroup.balance, LedgerField.amount);

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(ledgerInputProvider.notifier).initFor([cellA, cellB]);
  });

  test('入力可能でないセルは選択されない', () {
    container.read(ledgerInputProvider.notifier).selectCell(
          (9, LedgerColumnGroup.balance, LedgerField.amount),
        );
    expect(container.read(ledgerInputProvider).selectedCell, isNull);
  });

  test('桁入力・000・バックスペース・クリアが正しく動く', () {
    final notifier = container.read(ledgerInputProvider.notifier);
    notifier.selectCell(cellA);

    notifier.appendDigit('1');
    notifier.appendDigit('2');
    expect(container.read(ledgerInputProvider).valueAt(cellA), 12);

    notifier.appendTripleZero();
    expect(container.read(ledgerInputProvider).valueAt(cellA), 12000);

    notifier.backspaceAmount();
    expect(container.read(ledgerInputProvider).valueAt(cellA), 1200);

    notifier.clearAmount();
    expect(container.read(ledgerInputProvider).valueAt(cellA), isNull);
  });

  test('桁数上限(99999999)を超える入力は無視される', () {
    final notifier = container.read(ledgerInputProvider.notifier);
    notifier.selectCell(cellA);
    for (final d in '999999999'.split('')) {
      notifier.appendDigit(d);
    }
    expect(container.read(ledgerInputProvider).valueAt(cellA), 99999999);
  });

  test('confirmAmountで次の未入力セルへフォーカスが移り、最後なら選択解除される', () {
    final notifier = container.read(ledgerInputProvider.notifier);
    notifier.selectCell(cellA);
    notifier.appendDigit('5');

    notifier.confirmAmount();
    expect(container.read(ledgerInputProvider).selectedCell, cellB);

    notifier.appendDigit('7');
    notifier.confirmAmount();
    expect(container.read(ledgerInputProvider).selectedCell, isNull);
  });
}
