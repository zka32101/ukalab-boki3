import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 仕訳テーブルの1行（入力中。借方・貸方とも科目/金額は未入力ならnull）。
class JournalLineInputRow {
  const JournalLineInputRow({
    this.debitAccount,
    this.debitAmount,
    this.creditAccount,
    this.creditAmount,
  });

  final String? debitAccount;
  final int? debitAmount;
  final String? creditAccount;
  final int? creditAmount;

  JournalLineInputRow copyWith({
    String? Function()? debitAccount,
    int? Function()? debitAmount,
    String? Function()? creditAccount,
    int? Function()? creditAmount,
  }) =>
      JournalLineInputRow(
        debitAccount: debitAccount != null ? debitAccount() : this.debitAccount,
        debitAmount: debitAmount != null ? debitAmount() : this.debitAmount,
        creditAccount: creditAccount != null ? creditAccount() : this.creditAccount,
        creditAmount: creditAmount != null ? creditAmount() : this.creditAmount,
      );

  bool get isEmpty =>
      debitAccount == null &&
      debitAmount == null &&
      creditAccount == null &&
      creditAmount == null;

  @override
  bool operator ==(Object other) =>
      other is JournalLineInputRow &&
      other.debitAccount == debitAccount &&
      other.debitAmount == debitAmount &&
      other.creditAccount == creditAccount &&
      other.creditAmount == creditAmount;

  @override
  int get hashCode => Object.hash(debitAccount, debitAmount, creditAccount, creditAmount);
}

/// 入力セルの入力項目（科目か金額か）。
enum JournalCellField { account, amount }

/// 選択中のセル。
class JournalCellRef {
  const JournalCellRef({
    required this.rowIndex,
    required this.side,
    required this.field,
  });

  final int rowIndex;
  final JournalSide side;
  final JournalCellField field;

  @override
  bool operator ==(Object other) =>
      other is JournalCellRef &&
      other.rowIndex == rowIndex &&
      other.side == side &&
      other.field == field;

  @override
  int get hashCode => Object.hash(rowIndex, side, field);
}

/// 仕訳入力テーブル全体の状態。
class JournalInputState {
  const JournalInputState({
    required this.rows,
    this.selectedCell,
    this.history = const [],
  });

  factory JournalInputState.initial({int rowCount = 1}) => JournalInputState(
        rows: List.generate(rowCount, (_) => const JournalLineInputRow()),
      );

  final List<JournalLineInputRow> rows;
  final JournalCellRef? selectedCell;

  /// Undo用の履歴（直前の `rows` のスナップショット）。
  final List<List<JournalLineInputRow>> history;

  static const maxRows = 5;
  static const maxHistory = 20;

  int get debitTotal => _sum((r) => r.debitAmount);
  int get creditTotal => _sum((r) => r.creditAmount);
  bool get balanced => debitTotal == creditTotal;

  int _sum(int? Function(JournalLineInputRow) pick) =>
      rows.fold(0, (sum, r) => sum + (pick(r) ?? 0));

  /// 入力済みの行だけを `JournalLine` のリストに変換する（採点に渡す用）。
  List<JournalLine> toJournalLines() {
    final lines = <JournalLine>[];
    for (final row in rows) {
      if (row.debitAccount != null && row.debitAmount != null) {
        lines.add(
          JournalLine(side: JournalSide.debit, account: row.debitAccount!, amount: row.debitAmount!),
        );
      }
      if (row.creditAccount != null && row.creditAmount != null) {
        lines.add(
          JournalLine(side: JournalSide.credit, account: row.creditAccount!, amount: row.creditAmount!),
        );
      }
    }
    return lines;
  }

  JournalInputState copyWith({
    List<JournalLineInputRow>? rows,
    JournalCellRef? Function()? selectedCell,
    List<List<JournalLineInputRow>>? history,
  }) =>
      JournalInputState(
        rows: rows ?? this.rows,
        selectedCell: selectedCell != null ? selectedCell() : this.selectedCell,
        history: history ?? this.history,
      );
}
