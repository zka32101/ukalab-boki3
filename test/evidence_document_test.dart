import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/evidence_input/evidence_document.dart';

void main() {
  test('複数品目＋合計＋支払条件の証ひょうを正しく分解する', () {
    const prompt = '仕入先から次の納品書（兼請求書）を受け取った。'
        '「品名A 5個×1,000円＝5,000円、品名B 3個×2,000円＝6,000円、合計11,000円、代金は月末締め翌月払い」。'
        'この取引を仕訳しなさい。';

    final doc = parseEvidenceDocument(prompt);

    expect(doc, isNotNull);
    expect(doc!.narrative, '仕入先から次の納品書（兼請求書）を受け取った。');
    expect(doc.title, '納品書（兼請求書）');
    expect(doc.items, [
      '品名A 5個×1,000円＝5,000円',
      '品名B 3個×2,000円＝6,000円',
      '合計11,000円',
      '代金は月末締め翌月払い',
    ]);
    expect(doc.instruction, 'この取引を仕訳しなさい。');
  });

  test('「」の後に追加の処理条件がある場合、指示文に保持される', () {
    const prompt = '仕入先から次の納品書（兼請求書）を受け取った。'
        '「商品代金　20,000円、送料　1,000円、合計　21,000円、代金は掛け」。'
        '送料は仕入原価に含めて処理する。この取引を仕訳しなさい。';

    final doc = parseEvidenceDocument(prompt);

    expect(doc, isNotNull);
    expect(doc!.instruction, '送料は仕入原価に含めて処理する。この取引を仕訳しなさい。');
  });

  test('単一の項目だけの領収書も分解できる', () {
    const prompt = '出張した従業員から、次の領収書を添えて旅費交通費の精算を受け、現金で支払った。'
        '「新幹線運賃 8,500円」。この取引を仕訳しなさい。';

    final doc = parseEvidenceDocument(prompt);

    expect(doc, isNotNull);
    expect(doc!.title, '領収書');
    expect(doc.items, ['新幹線運賃 8,500円']);
  });

  test('「」で証ひょうの内容を囲んでいない問題は null を返す', () {
    const prompt = '得意先から売掛金100,000円の回収として、振込手数料440円が差し引かれた残額が'
        '普通預金口座に入金された旨の振込明細を受け取った。この取引を仕訳しなさい。';

    expect(parseEvidenceDocument(prompt), isNull);
  });
}
