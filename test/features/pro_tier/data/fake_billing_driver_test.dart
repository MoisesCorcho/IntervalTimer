import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/pro_tier/data/fake_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/pro_tier/domain/purchase_result.dart';

void main() {
  late AppDatabase db;
  late PreferencesRepository prefs;
  late FakeBillingDriver driver;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = PreferencesRepository(db);
    driver = FakeBillingDriver(preferencesRepository: prefs);
  });

  tearDown(() async {
    await db.close();
  });

  group('FakeBillingDriver (F06)', () {
    test('isMockDriver is true', () {
      expect(driver.isMockDriver, isTrue);
    });

    test('getAvailableProducts returns 3 curated tiers (R5, R6)', () async {
      final products = await driver.getAvailableProducts();
      expect(products.length, 3);

      final monthly = products.firstWhere((p) => p.period == BillingPeriod.monthly);
      expect(monthly.id, 'interval_timer_pro_monthly');
      expect(monthly.priceFormatted, '\$2.99');
      expect(monthly.hasFreeTrial, isFalse);

      final annual = products.firstWhere((p) => p.period == BillingPeriod.annual);
      expect(annual.id, 'interval_timer_pro_annual');
      expect(annual.priceFormatted, '\$17.99');
      expect(annual.hasFreeTrial, isTrue);
      expect(annual.discountPercentage, 50);

      final lifetime = products.firstWhere((p) => p.period == BillingPeriod.lifetime);
      expect(lifetime.id, 'interval_timer_pro_lifetime');
      expect(lifetime.priceFormatted, '\$29.99');
    });

    test('isPro returns initial false and updates with toggleMockPro (R1, R14)', () async {
      expect(await driver.isPro(), isFalse);

      await driver.toggleMockPro(true);
      expect(await driver.isPro(), isTrue);
      expect(await prefs.isProUser(), isTrue);

      await driver.toggleMockPro(false);
      expect(await driver.isPro(), isFalse);
      expect(await prefs.isProUser(), isFalse);
    });

    test('purchase simulates successful purchase and persists Pro (R6)', () async {
      final products = await driver.getAvailableProducts();
      final annual = products.firstWhere((p) => p.period == BillingPeriod.annual);

      final result = await driver.purchase(annual);
      expect(result.status, PurchaseStatus.success);
      expect(await driver.isPro(), isTrue);
      expect(await prefs.isProUser(), isTrue);
    });

    test('purchase respects mockFailure status when configured (R11)', () async {
      driver.simulateNextFailure = true;
      final products = await driver.getAvailableProducts();

      final result = await driver.purchase(products.first);
      expect(result.status, PurchaseStatus.error);
      expect(result.errorMessage, isNotNull);
      expect(await driver.isPro(), isFalse);
    });

    test('purchase respects mockCancellation status when configured (R11)', () async {
      driver.simulateNextCancellation = true;
      final products = await driver.getAvailableProducts();

      final result = await driver.purchase(products.first);
      expect(result.status, PurchaseStatus.cancelled);
      expect(await driver.isPro(), isFalse);
    });

    test('restorePurchases restores previous purchase if exists (R7, R12)', () async {
      // First, when nothing was purchased:
      var result = await driver.restorePurchases();
      expect(result.status, PurchaseStatus.error);
      expect(result.errorMessage, contains('No'));

      // Now simulate a prior purchase:
      driver.hasPriorPurchase = true;
      result = await driver.restorePurchases();
      expect(result.status, PurchaseStatus.success);
      expect(await driver.isPro(), isTrue);
    });
  });
}
