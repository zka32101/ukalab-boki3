/// 入金伝票・出金伝票の入力項目（相手科目か金額か）。
enum VoucherSelectedField { account, amount }

/// 入金伝票・出金伝票の入力状態。現金側は伝票の種類で決まるため入力させない。
/// 相手科目と金額の2項目だけを持つ。
class VoucherInputState {
  const VoucherInputState({this.account, this.amount, this.selectedField});

  final String? account;
  final int? amount;
  final VoucherSelectedField? selectedField;

  VoucherInputState copyWith({
    String? Function()? account,
    int? Function()? amount,
    VoucherSelectedField? Function()? selectedField,
  }) =>
      VoucherInputState(
        account: account != null ? account() : this.account,
        amount: amount != null ? amount() : this.amount,
        selectedField: selectedField != null ? selectedField() : this.selectedField,
      );
}
