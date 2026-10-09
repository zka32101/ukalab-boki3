import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// [term] を [showTermCard] でボトムシート表示する。関連用語をタップすると、
/// 前のカードを閉じて該当の用語カードを開き直す（再帰的に辿れる）。
///
/// 用語集一覧（[TermListPage]）・解説画面（[ExplanationWithTerms]）の
/// 両方から呼ぶ共通ロジック。
void openTermCard(BuildContext context, List<Term> all, Term term) {
  Term? findTerm(String termId) {
    for (final t in all) {
      if (t.termId == termId) return t;
    }
    return null;
  }

  void open(Term t) {
    showTermCard(
      context,
      term: t.term,
      headline: t.headline,
      definition: t.definition,
      analogy: t.analogy,
      commonMistake: t.commonMistake,
      relatedTerms: [
        for (final id in t.relatedTermIds)
          if (findTerm(id) case final related?) RelatedTermRef(termId: related.termId, label: related.term),
      ],
      onRelatedTermTap: (termId) {
        final related = findTerm(termId);
        if (related != null) {
          Navigator.of(context).pop();
          open(related);
        }
      },
    );
  }

  open(term);
}
