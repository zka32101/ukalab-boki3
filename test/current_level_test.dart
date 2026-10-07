import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/exam_data/current_level.dart';

void main() {
  test('2027年3月31日は旧配点levelを返す', () {
    expect(currentLevelId(now: DateTime(2027, 3, 31)), 'level3_until_2027_03');
  });

  test('2027年4月1日は新配点levelを返す', () {
    expect(currentLevelId(now: DateTime(2027, 4, 1)), 'level3_from_2027_04');
  });

  test('2026年11月15日（第174回）は旧配点levelを返す', () {
    expect(currentLevelId(now: DateTime(2026, 11, 15)), 'level3_until_2027_03');
  });

  test('2027年4月1日より後も新配点levelを返す', () {
    expect(currentLevelId(now: DateTime(2027, 12, 31)), 'level3_from_2027_04');
  });
}
