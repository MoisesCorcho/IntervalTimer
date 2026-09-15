import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/pro_tier/application/pro_providers.dart';
import 'package:interval_timer/features/pro_tier/data/fake_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/data/revenue_cat_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/data/purchases_delegate.dart';
import 'package:interval_timer/features/workout_builder/application/workout_providers.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

class MinimalPurchasesDelegate implements PurchasesDelegate {
  @override
  Future<void> configure(String apiKey) async {}

  @override
  Future<rc.CustomerInfo> getCustomerInfo() async {
    return const rc.CustomerInfo(
      rc.EntitlementInfos({}, {}),
      {},
      [],
      [],
      [],
      '2026-09-15T00:00:00Z',
      'user_1',
      {},
      '2026-09-15T00:00:00Z',
    );
  }

  @override
  Stream<rc.CustomerInfo> get onCustomerInfoUpdated => const Stream.empty();

  @override
  Future<rc.Offerings> getOfferings() async => const rc.Offerings({});

  @override
  Future<rc.CustomerInfo> purchasePackage(rc.Package package) async {
    return getCustomerInfo();
  }

  @override
  Future<rc.CustomerInfo> restorePurchases() async => getCustomerInfo();

  @override
  void dispose() {}
}

void main() {
  late AppDatabase db;
  late PreferencesRepository prefsRepo;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    prefsRepo = PreferencesRepository(db);
    container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('billingRepositoryProvider conditional resolution', () {
    test('resolves to FakeBillingDriver by default in test/dev environment', () {
      final billingRepo = container.read(billingRepositoryProvider);

      expect(billingRepo, isA<FakeBillingDriver>());
      expect(billingRepo.isMockDriver, isTrue);
    });

    test('can be swapped with RevenueCatBillingDriver cleanly via ProviderScope', () {
      final rcDriver = RevenueCatBillingDriver(
        preferencesRepository: prefsRepo,
        purchasesDelegate: MinimalPurchasesDelegate(),
        apiKeyOverride: 'test_key',
      );

      final customContainer = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(prefsRepo),
          billingRepositoryProvider.overrideWithValue(rcDriver),
        ],
      );
      addTearDown(customContainer.dispose);

      final billingRepo = customContainer.read(billingRepositoryProvider);

      expect(billingRepo, isA<RevenueCatBillingDriver>());
      expect(billingRepo.isMockDriver, isFalse);
    });
  });
}
