import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../exam_data/exam_data_cache.dart';
import 'learned_terms_store.dart';
import 'term_card_opener.dart';

enum _LearnedFilter { all, learned, unlearned }

/// 「学ぶ」タブから開く用語集。一覧から選ぶと [showTermCard] で解説をボトムシートに開く
/// （決定50「専門用語の解説（全アプリ共通）」）。
///
/// 一覧の各用語には「覚えた」チェックを付けられ、[LearnedTermsStore] に
/// 端末内保存する。「未習得」に絞って復習したい用語だけを表示できる。
class TermListPage extends StatefulWidget {
  const TermListPage({super.key});

  @override
  State<TermListPage> createState() => _TermListPageState();
}

class _TermListPageState extends State<TermListPage> {
  late Future<List<Term>> _termsFuture;
  final _learnedStore = LearnedTermsStore();
  final _searchController = TextEditingController();
  String _query = '';
  Set<String> _learnedIds = {};
  _LearnedFilter _filter = _LearnedFilter.all;

  @override
  void initState() {
    super.initState();
    _termsFuture = loadTerms();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
    _learnedStore.load().then((ids) {
      if (mounted) setState(() => _learnedIds = ids);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleLearned(Term term) async {
    final learned = !_learnedIds.contains(term.termId);
    await _learnedStore.setLearned(term.termId, learned);
    setState(() {
      if (learned) {
        _learnedIds = {..._learnedIds, term.termId};
      } else {
        _learnedIds = {..._learnedIds}..remove(term.termId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('用語集')),
      body: FutureBuilder<List<Term>>(
        future: _termsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasError) {
            return ErrorState(message: '読み込みに失敗しました: ${snapshot.error}');
          }
          final all = snapshot.data!;
          final filtered = all.where((t) {
            final matchesQuery = _query.isEmpty || t.term.contains(_query) || t.headline.contains(_query);
            final isLearned = _learnedIds.contains(t.termId);
            final matchesFilter = switch (_filter) {
              _LearnedFilter.all => true,
              _LearnedFilter.learned => isLearned,
              _LearnedFilter.unlearned => !isLearned,
            };
            return matchesQuery && matchesFilter;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '用語を検索',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<_LearnedFilter>(
                    segments: const [
                      ButtonSegment(value: _LearnedFilter.all, label: Text('すべて')),
                      ButtonSegment(value: _LearnedFilter.learned, label: Text('覚えた')),
                      ButtonSegment(value: _LearnedFilter.unlearned, label: Text('未習得')),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (selection) => setState(() => _filter = selection.first),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(message: '該当する用語が見つかりません。', icon: Icons.search_off)
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final term = filtered[index];
                          final learned = _learnedIds.contains(term.termId);
                          return ListTile(
                            leading: Checkbox(
                              value: learned,
                              onChanged: (_) => _toggleLearned(term),
                            ),
                            title: Text(term.term),
                            subtitle: Text(
                              term.headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () => openTermCard(context, all, term),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
