import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../exam_data/exam_data_cache.dart';
import 'company_scenario_play_page.dart';

/// 「学ぶ」タブから開く会社経営モードのシナリオ選択画面。
///
/// `docs/company_mode_v1_design.md` のPhase 1。初回は業種違いの3シナリオを
/// 全て無料で公開する。
class CompanyScenarioListPage extends StatefulWidget {
  const CompanyScenarioListPage({super.key});

  @override
  State<CompanyScenarioListPage> createState() => _CompanyScenarioListPageState();
}

class _CompanyScenarioListPageState extends State<CompanyScenarioListPage> {
  late Future<List<CompanyScenario>> _scenariosFuture;

  @override
  void initState() {
    super.initState();
    _scenariosFuture = loadCompanyScenarios();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('会社を経営する')),
      body: FutureBuilder<List<CompanyScenario>>(
        future: _scenariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasError) {
            return ErrorState(message: '読み込みに失敗しました: ${snapshot.error}');
          }
          final scenarios = snapshot.data!;
          if (scenarios.isEmpty) {
            return const EmptyState(message: '利用できるシナリオがありません。', icon: Icons.storefront_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: scenarios.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final scenario = scenarios[index];
              return Card(
                child: ListTile(
                  title: Text(scenario.companyName),
                  subtitle: Text(
                    '${scenario.industry} ・ 全${scenario.turns.length}ターン',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CompanyScenarioPlayPage(scenario: scenario)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
