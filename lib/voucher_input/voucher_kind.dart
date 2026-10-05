/// 伝票の種類（入金・出金・振替）。
enum VoucherKind { receipt, payment, transfer }

extension VoucherKindLabel on VoucherKind {
  String get label => switch (this) {
        VoucherKind.receipt => '入金伝票',
        VoucherKind.payment => '出金伝票',
        VoucherKind.transfer => '振替伝票',
      };
}

/// `topicId` から伝票の種類を判定する。対象外（通常の仕訳問題）なら null。
VoucherKind? voucherKindOfTopic(String topicId) => switch (topicId) {
      'voucher_receipt' => VoucherKind.receipt,
      'voucher_payment' => VoucherKind.payment,
      'voucher_transfer' => VoucherKind.transfer,
      _ => null,
    };
