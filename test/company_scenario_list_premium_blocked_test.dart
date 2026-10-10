import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_boki3/company_mode/company_mode_history_store.dart';
import 'package:ukalab_boki3/company_mode/company_scenario_list_page.dart';
import 'package:ukalab_boki3/company_mode/company_scenario_play_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 会社経営モードの有料化（`freeCompanyScenarioIds` 以外はプレミアム限定）の検証。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('有料シナリオ（法律事務所つくし）はpremiumでなければ案内を出して開かない', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final historyStore = InMemoryCompanyModeHistoryStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementServiceProvider.overrideWithValue(
            FakeEntitlementService(initial: const EntitlementState(hasPremium: false)),
          ),
        ],
        child: MaterialApp(
          home: CompanyScenarioListPage(historyStore: historyStore),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    await tester.tap(find.text('法律事務所つくし'));
    await tester.pump();
    expect(find.textContaining('プレミアムの機能'), findsOneWidget);
    expect(find.byType(CompanyScenarioPlayPage), findsNothing);
  });
}
