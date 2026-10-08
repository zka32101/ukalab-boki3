import 'package:shared_preferences/shared_preferences.dart';

/// 「覚えた」にチェックした用語の `termId` を端末内（[SharedPreferences]）に
/// 保存する。用語集一覧の「覚えた／未習得」フィルタに使う。
class LearnedTermsStore {
  static const _key = 'ukalab_boki3_learned_term_ids';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  Future<void> setLearned(String termId, bool learned) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key)?.toSet() ?? {};
    if (learned) {
      ids.add(termId);
    } else {
      ids.remove(termId);
    }
    await prefs.setStringList(_key, ids.toList());
  }
}
