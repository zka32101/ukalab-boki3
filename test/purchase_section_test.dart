import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_boki3/purchase/purchase_section.dart';

const _noAds = EntitlementOffer(
  id: 'noads',
  productId: 'boki3_noads',
  title: '広告非表示',
  priceString: '¥480',
);
const _premium = EntitlementOffer(
  id: 'premium',
  productId: 'boki3_premium',
  title: 'プレミアム',
  priceString: '¥1,500',
);

FakeEntitlementService _service() => FakeEntitlementService(
      availableOffers: const [_noAds, _premium],
      grantOnPurchase: const {
        'boki3_noads': EntitlementState(hasNoAds: true),
        'boki3_premium': EntitlementState(hasPremium: true),
      },
    );

Widget _app(FakeEntitlementService service) => ProviderScope(
      overrides: [entitlementServiceProvider.overrideWithValue(service)],
      child: const MaterialApp(home: Scaffold(body: PurchaseSection())),
    );

void main() {
  testWidgets('無料の間は購入ボタンが出る', (tester) async {
    await tester.pumpWidget(_app(_service()));
    await tester.pumpAndSettle();
    expect(find.text('¥480'), findsOneWidget);
    expect(find.text('¥1,500'), findsOneWidget);
  });

  testWidgets('プレミアムを購入すると購入済み表示になり、ボタンが消える', (tester) async {
    await tester.pumpWidget(_app(_service()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('¥1,500'));
    await tester.pumpAndSettle();
    expect(find.text('プレミアムを購入済みです'), findsOneWidget);
    expect(find.text('¥1,500'), findsNothing);
  });

  testWidgets('復元できる購入が無ければ、その旨を出す', (tester) async {
    await tester.pumpWidget(_app(_service()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('購入を復元'));
    await tester.pumpAndSettle();
    expect(find.text('復元できる購入がありませんでした。'), findsOneWidget);
  });
}
