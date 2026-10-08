import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../exam_data/exam_data_cache.dart';

/// 「学ぶ」タブから開く用語集。一覧から選ぶと [showTermCard] で解説をボトムシートに開く
/// （決定50「専門用語の解説（全アプリ共通）」）。
class TermListPage extends StatefulWidget {
  const TermListPage({super.key});

  @override
  State<TermListPage> createState() => _TermListPageState();
}

class _TermListPageState extends State<TermListPage> {
  late Future<List<Term>> _termsFuture;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _termsFuture = loadTerms();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Term? _findTerm(List<Term> all, String termId) {
    for (final t in all) {
      if (t.termId == termId) return t;
    }
    return null;
  }

  void _openTerm(BuildContext context, List<Term> all, Term term) {
    showTermCard(
      context,
      term: term.term,
      headline: term.headline,
      definition: term.definition,
      analogy: term.analogy,
      commonMistake: term.commonMistake,
      relatedTerms: [
        for (final id in term.relatedTermIds)
          if (_findTerm(all, id) case final related?)
            RelatedTermRef(termId: related.termId, label: related.term),
      ],
      onRelatedTermTap: (termId) {
        final related = _findTerm(all, termId);
        if (related != null) {
          Navigator.of(context).pop();
          _openTerm(context, all, related);
        }
      },
    );
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
          final filtered = _query.isEmpty
              ? all
              : all.where((t) => t.term.contains(_query) || t.headline.contains(_query)).toList();

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
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(message: '該当する用語が見つかりません。', icon: Icons.search_off)
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final term = filtered[index];
                          return ListTile(
                            title: Text(term.term),
                            subtitle: Text(
                              term.headline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () => _openTerm(context, all, term),
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
