import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_exam/mock_exam_page.dart';
import 'practice/practice_page.dart';
import 'progress/progress_store.dart';
import 'progress/progress_summary_card.dart';
import 'records/records_page.dart';
import 'settings/settings_page.dart';

/// 演習・模擬試験の解答記録の保存先。端末内保存（アプリ全体で共有）。
final ProgressStore appProgressStore = SharedPreferencesProgressStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedThemeMode();
  runApp(const ProviderScope(child: UkalabBoki3App()));
}

class UkalabBoki3App extends StatelessWidget {
  const UkalabBoki3App({super.key});

  static const _field = UkalabField.biz;
  static const _cert = UkalabCert.boki3;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'うかラボ 簿記3級',
        theme: UkalabTheme.light(field: _field, cert: _cert),
        darkTheme: UkalabTheme.dark(field: _field, cert: _cert),
        themeMode: mode,
        home: UkalabShell(
          pages: [
            const _HomePage(),
            const _LearnPage(),
            const _MockExamTab(),
            RecordsPage(progressStore: appProgressStore),
            SettingsPage(progressStore: appProgressStore),
          ],
        ),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Text('うかラボ 簿記3級', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 16),
        ProgressSummaryCard(store: appProgressStore),
      ],
    );
  }
}

/// 「学ぶ」タブ。科目別の練習（第1〜3問）と、全問をまとめて解く問題集への入口。
class _LearnPage extends StatelessWidget {
  const _LearnPage();

  /// `assets/exam/boki3.exam.json` の `subjects` と対応する
  /// （subjectId, 表示名）。3つで固定のため、ここでは読み込まずハードコードする。
  static const _subjects = [
    ('q1_shiwake', '第1問 仕訳'),
    ('q2_choubo', '第2問 帳簿・伝票等'),
    ('q3_kessan', '第3問 決算'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(child: Text('学ぶ', style: theme.textTheme.titleLarge)),
        const SizedBox(height: 24),
        Text('科目別に練習する', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final (subjectId, name) in _subjects)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PracticePage(
                      progressStore: appProgressStore,
                      subjectId: subjectId,
                      title: '$nameを練習する',
                    ),
                  ),
                ),
                child: Align(alignment: Alignment.centerLeft, child: Text(name)),
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PracticePage(progressStore: appProgressStore)),
          ),
          child: const Text('すべての問題を練習する（問題集）'),
        ),
      ],
    );
  }
}

/// 「模擬」タブ。本試験形式（出題数・制限時間・配点）で1回通しで解く
/// 模擬試験モードへの入口。
class _MockExamTab extends StatelessWidget {
  const _MockExamTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MockExamPage(progressStore: appProgressStore)),
        ),
        child: const Text('模擬試験を始める'),
      ),
    );
  }
}
