import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_timer/data/local/database.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/pro_tier/data/purchases_delegate.dart';
import 'package:interval_timer/features/pro_tier/data/revenue_cat_billing_driver.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/pro_tier/domain/purchase_result.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

rc.CustomerInfo _createCustomerInfo({required bool isPro}) {
  final entitlement = rc.EntitlementInfo(
    'pro',
    isPro,
    isPro,
    '2026-09-15T00:00:00Z',
    '2026-09-15T00:00:00Z',
    'repulse_pro_annual',
    true,
    ownershipType: rc.OwnershipType.purchased,
    store: rc.Store.playStore,
  );

  return rc.CustomerInfo(
    rc.EntitlementInfos(
      isPro ? {'pro': entitlement} : {},
      isPro ? {'pro': entitlement} : {},
    ),
    const {},
    isPro ? const ['repulse_pro_annual'] : const [],
    isPro ? const ['repulse_pro_annual'] : const [],
    const [],
    '2026-09-15T00:00:00Z',
    'test_user_id',
    const {},
    '2026-09-15T00:00:00Z',
  );
}

rc.Package _createPackage({
  required String identifier,
  required rc.PackageType packageType,
  required String productIdentifier,
  required String title,
  required String description,
  required double price,
  required String priceString,
}) {
  return rc.Package(
    identifier,
    packageType,
    rc.StoreProduct(
      productIdentifier,
      description,
      title,
      price,
      priceString,
      'USD',
    ),
    const rc.PresentedOfferingContext('default', null, null),
  );
}

class FakePurchasesDelegate implements PurchasesDelegate {
  bool configured = false;
  int configureCallCount = 0;
  String? configuredApiKey;
  bool isDisposed = false;
  rc.CustomerInfo? customerInfoToReturn;
  rc.Offerings? offeringsToReturn;
  Object? errorToThrow;

  final _controller = StreamController<rc.CustomerInfo>.broadcast();

  @override
  Future<void> configure(String apiKey) async {
    configureCallCount++;
    configured = true;
    configuredApiKey = apiKey;
  }

  @override
  Future<rc.CustomerInfo> getCustomerInfo() async {
    if (errorToThrow != null) throw errorToThrow!;
    return customerInfoToReturn ?? _createCustomerInfo(isPro: false);
  }

  @override
  Stream<rc.CustomerInfo> get onCustomerInfoUpdated => _controller.stream;

  void emitCustomerInfo(rc.CustomerInfo info) {
    _controller.add(info);
  }

  @override
  Future<rc.Offerings> getOfferings() async {
    if (errorToThrow != null) throw errorToThrow!;
    return offeringsToReturn ?? const rc.Offerings({});
  }

  @override
  Future<rc.CustomerInfo> purchasePackage(rc.Package package) async {
    if (errorToThrow != null) throw errorToThrow!;
    return customerInfoToReturn ?? _createCustomerInfo(isPro: true);
  }

  @override
  Future<rc.CustomerInfo> restorePurchases() async {
    if (errorToThrow != null) throw errorToThrow!;
    return customerInfoToReturn ?? _createCustomerInfo(isPro: true);
  }

  @override
  void dispose() {
    isDisposed = true;
    _controller.close();
  }
}

void main() {
  late AppDatabase db;
  late PreferencesRepository prefsRepo;
  late FakePurchasesDelegate fakeDelegate;
  late RevenueCatBillingDriver driver;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    prefsRepo = PreferencesRepository(db);
    fakeDelegate = FakePurchasesDelegate();
    driver = RevenueCatBillingDriver(
      preferencesRepository: prefsRepo,
      purchasesDelegate: fakeDelegate,
      apiKeyOverride: 'test_api_key_123',
    );
  });

  tearDown(() async {
    driver.dispose();
    await db.close();
  });

  group('RevenueCatBillingDriver', () {
    test('isMockDriver returns false', () {
      expect(driver.isMockDriver, isFalse);
    });

    test('toggleMockPro throws UnsupportedError in production driver', () async {
      expect(() => driver.toggleMockPro(true), throwsUnsupportedError);
    });

    test('concurrent operations memoize configuration and only configure once', () async {
      await Future.wait([
        driver.isPro(),
        driver.getAvailableProducts(),
        driver.isPro(),
      ]);

      expect(fakeDelegate.configureCallCount, equals(1));
    });

    test('isPro returns true and syncs preferences when entitlement is active', () async {
      fakeDelegate.customerInfoToReturn = _createCustomerInfo(isPro: true);

      final isPro = await driver.isPro();

      expect(isPro, isTrue);
      expect(await prefsRepo.isProUser(), isTrue);
      expect(fakeDelegate.configured, isTrue);
    });

    test('isPro returns false and syncs preferences when entitlement is inactive', () async {
      await prefsRepo.setIsProUser(true);
      fakeDelegate.customerInfoToReturn = _createCustomerInfo(isPro: false);

      final isPro = await driver.isPro();

      expect(isPro, isFalse);
      expect(await prefsRepo.isProUser(), isFalse);
    });

    test('isPro falls back to SQLite preferences when delegate throws (offline resilience)', () async {
      await prefsRepo.setIsProUser(true);
      fakeDelegate.errorToThrow = Exception('Network offline');

      final isPro = await driver.isPro();

      expect(isPro, isTrue);
    });

    test('getAvailableProducts maps offerings to domain ProductPackage models', () async {
      final annualPkg = _createPackage(
        identifier: '\$rc_annual',
        packageType: rc.PackageType.annual,
        productIdentifier: 'repulse_pro_annual',
        title: 'Anual',
        description: '7 días gratis, luego \$17.99/año',
        price: 17.99,
        priceString: '\$17.99',
      );
      final monthlyPkg = _createPackage(
        identifier: '\$rc_monthly',
        packageType: rc.PackageType.monthly,
        productIdentifier: 'repulse_pro_monthly',
        title: 'Mensual',
        description: 'Facturación mensual',
        price: 2.99,
        priceString: '\$2.99',
      );
      final lifetimePkg = _createPackage(
        identifier: '\$rc_lifetime',
        packageType: rc.PackageType.lifetime,
        productIdentifier: 'repulse_pro_lifetime',
        title: 'De por vida',
        description: 'Pago único',
        price: 29.99,
        priceString: '\$29.99',
      );

      final offering = rc.Offering(
        'default',
        'Default Offering',
        const {},
        [annualPkg, monthlyPkg, lifetimePkg],
        annual: annualPkg,
        monthly: monthlyPkg,
        lifetime: lifetimePkg,
      );

      fakeDelegate.offeringsToReturn = rc.Offerings(
        {'default': offering},
        current: offering,
      );

      final products = await driver.getAvailableProducts();

      expect(products.length, equals(3));
      final annual = products.firstWhere((p) => p.period == BillingPeriod.annual);
      expect(annual.id, equals('repulse_pro_annual'));
      expect(annual.priceFormatted, equals('\$17.99'));
      expect(annual.priceNumeric, equals(17.99));
      expect(annual.discountPercentage, equals(50));
      expect(annual.hasFreeTrial, isTrue);

      final lifetime = products.firstWhere((p) => p.period == BillingPeriod.lifetime);
      expect(lifetime.id, equals('repulse_pro_lifetime'));
      expect(lifetime.period, equals(BillingPeriod.lifetime));
      expect(lifetime.hasFreeTrial, isFalse);
    });

    test('purchase returns success and persists is_pro when purchase succeeds', () async {
      final annualPkg = _createPackage(
        identifier: '\$rc_annual',
        packageType: rc.PackageType.annual,
        productIdentifier: 'repulse_pro_annual',
        title: 'Anual',
        description: '7 días gratis',
        price: 17.99,
        priceString: '\$17.99',
      );
      final offering = rc.Offering(
        'default',
        'Default',
        const {},
        [annualPkg],
        annual: annualPkg,
      );
      fakeDelegate.offeringsToReturn = rc.Offerings({'default': offering}, current: offering);
      await driver.getAvailableProducts();

      fakeDelegate.customerInfoToReturn = _createCustomerInfo(isPro: true);

      const domainPkg = ProductPackage(
        id: 'repulse_pro_annual',
        title: 'Anual',
        description: '7 días gratis',
        priceFormatted: '\$17.99',
        priceNumeric: 17.99,
        period: BillingPeriod.annual,
      );

      final result = await driver.purchase(domainPkg);

      expect(result.status, equals(PurchaseStatus.success));
      expect(await prefsRepo.isProUser(), isTrue);
    });

    test('purchase returns cancelled when PlatformException has purchaseCancelledError', () async {
      final annualPkg = _createPackage(
        identifier: '\$rc_annual',
        packageType: rc.PackageType.annual,
        productIdentifier: 'repulse_pro_annual',
        title: 'Anual',
        description: '7 días gratis',
        price: 17.99,
        priceString: '\$17.99',
      );
      final offering = rc.Offering(
        'default',
        'Default',
        const {},
        [annualPkg],
        annual: annualPkg,
      );
      fakeDelegate.offeringsToReturn = rc.Offerings({'default': offering}, current: offering);
      await driver.getAvailableProducts();

      // PurchasesErrorCode.purchaseCancelledError has value 1
      fakeDelegate.errorToThrow = PlatformException(
        code: '1',
        message: 'User cancelled',
      );

      const domainPkg = ProductPackage(
        id: 'repulse_pro_annual',
        title: 'Anual',
        description: '7 días gratis',
        priceFormatted: '\$17.99',
        priceNumeric: 17.99,
        period: BillingPeriod.annual,
      );

      final result = await driver.purchase(domainPkg);

      expect(result.status, equals(PurchaseStatus.cancelled));
      expect(await prefsRepo.isProUser(), isFalse);
    });

    test('restorePurchases returns success when active subscription is found', () async {
      fakeDelegate.customerInfoToReturn = _createCustomerInfo(isPro: true);

      final result = await driver.restorePurchases();

      expect(result.status, equals(PurchaseStatus.success));
      expect(await prefsRepo.isProUser(), isTrue);
    });

    test('restorePurchases returns error without wiping local offline pro when no active subs found', () async {
      await prefsRepo.setIsProUser(true);
      fakeDelegate.customerInfoToReturn = _createCustomerInfo(isPro: false);

      final result = await driver.restorePurchases();

      expect(result.status, equals(PurchaseStatus.error));
      // Preserved local offline entitlement
      expect(await prefsRepo.isProUser(), isTrue);
    });

    test('watchIsPro ensures configuration and syncs initial state and stream updates into SQLite', () async {
      fakeDelegate.customerInfoToReturn = _createCustomerInfo(isPro: true);

      driver.watchIsPro();

      // Verify watchIsPro triggered configuration and initial sync
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(fakeDelegate.configured, isTrue);
      expect(await prefsRepo.isProUser(), isTrue);

      // Verify subsequent stream updates sync into SQLite
      fakeDelegate.emitCustomerInfo(_createCustomerInfo(isPro: false));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(await prefsRepo.isProUser(), isFalse);
    });

    test('dispose cancels stream subscription and delegates disposal', () {
      driver.watchIsPro();
      driver.dispose();

      expect(fakeDelegate.isDisposed, isTrue);
    });
  });
}
