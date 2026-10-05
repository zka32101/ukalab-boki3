import 'package:flutter/material.dart';

/// 証ひょう読み取り問題の `prompt` から、証ひょう（領収書・請求書など）の
/// 記載内容を取り出した結果。問題文は「...。「品名A 5個×1,000円＝5,000円、
/// 合計5,000円」。...この取引を仕訳しなさい。」のように、`「」` で証ひょうの
/// 内容を囲む書き方で統一されている（問題データ作成時の自作ルール）ため、
/// それをそのままパースする。画像を使わず、既存のテキストデータだけで
/// 証ひょう風のカード表示を作る軽量な方法。
class EvidenceDocument {
  const EvidenceDocument({
    required this.narrative,
    required this.title,
    required this.icon,
    required this.items,
    required this.instruction,
  });

  /// 証ひょうを受け取った経緯の説明文（`「」` より前の部分）。
  final String narrative;

  /// 証ひょうの種類（領収書・請求書など）。
  final String title;
  final IconData icon;

  /// 証ひょうの記載項目（`「」` の中身を `、` で分割したもの）。
  final List<String> items;

  /// 証ひょうの後に続く指示文（`「」` より後の部分。追加の処理条件や
  /// 「この取引を仕訳しなさい。」などを含む）。
  final String instruction;
}

const _titleCandidates = <(String, IconData)>[
  ('納品書（兼請求書）', Icons.receipt),
  ('請求書', Icons.description),
  ('領収書', Icons.receipt_long),
  ('利用明細', Icons.credit_card),
  ('振込明細', Icons.account_balance),
  ('納品書', Icons.receipt),
];

(String, IconData) _detectTitle(String narrative) {
  for (final (title, icon) in _titleCandidates) {
    if (narrative.contains(title)) return (title, icon);
  }
  return ('証ひょう', Icons.article_outlined);
}

/// `prompt` から証ひょうの内容を取り出す。`「」` で囲まれた記載内容が
/// 見つからない問題（例: 振込明細の内容を地の文だけで説明している問題）は
/// null を返し、呼び出し側は通常のプロンプト表示にフォールバックする。
EvidenceDocument? parseEvidenceDocument(String prompt) {
  final openIndex = prompt.indexOf('「');
  final closeIndex = prompt.lastIndexOf('」');
  if (openIndex == -1 || closeIndex == -1 || closeIndex <= openIndex) return null;

  final narrative = prompt.substring(0, openIndex).trim();
  final quoted = prompt.substring(openIndex + 1, closeIndex);
  final items = quoted.split('、').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (items.isEmpty) return null;

  var instruction = prompt.substring(closeIndex + 1).trim();
  if (instruction.startsWith('。')) {
    instruction = instruction.substring(1).trim();
  }
  if (instruction.isEmpty) instruction = 'この取引を仕訳しなさい。';

  final (title, icon) = _detectTitle(narrative);
  return EvidenceDocument(
    narrative: narrative,
    title: title,
    icon: icon,
    items: items,
    instruction: instruction,
  );
}
