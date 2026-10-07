/// 2027年4月1日の配点改定（45/20/35→45/25/30、第174回までは旧配点）を境に、
/// 模擬試験で使う `levelId` を切り替える。
///
/// `now` はテスト用（省略時は現在時刻）。
const _cutover = (year: 2027, month: 4, day: 1);

String currentLevelId({DateTime? now}) {
  final reference = now ?? DateTime.now();
  final cutoverDate = DateTime(_cutover.year, _cutover.month, _cutover.day);
  return reference.isBefore(cutoverDate) ? 'level3_until_2027_03' : 'level3_from_2027_04';
}
