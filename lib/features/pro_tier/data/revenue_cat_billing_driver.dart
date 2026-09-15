import 'dart:async';
import 'package:flutter/services.dart';
import 'package:interval_timer/data/repositories/preferences_repository.dart';
import 'package:interval_timer/features/pro_tier/data/billing_repository.dart';
import 'package:interval_timer/features/pro_tier/data/purchases_delegate.dart';
import 'package:interval_timer/features/pro_tier/data/revenue_cat_config.dart';
import 'package:interval_timer/features/pro_tier/domain/product_package.dart';
import 'package:interval_timer/features/pro_tier/domain/purchase_result.dart' as domain;
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

/// Production implementation of [BillingRepository] backed by RevenueCat.
/// Integrates server-side receipt validation, Google Play Billing, and Apple StoreKit.
class RevenueCatBillingDriver implements BillingRepository {
  RevenueCatBillingDriver({
    required PreferencesRepository preferencesRepository,
    PurchasesDelegate? purchasesDelegate,
    String? entitlementId,
    String? apiKeyOverride,
  })  : _prefs = preferencesRepository,
        _delegate = purchasesDelegate ?? RevenueCatPurchasesDelegate(),
        _entitlementId = entitlementId ?? RevenueCatConfig.entitlementId,
        _apiKeyOverride = apiKeyOverride;

  final PreferencesRepository _prefs;
  final PurchasesDelegate _delegate;
  final String _entitlementId;
  final String? _apiKeyOverride;

  final Map<String, rc.Package> _packageCache = {};
  Future<void>? _configureFuture;
  StreamSubscription<rc.CustomerInfo>? _customerInfoSubscription;

  @override
  bool get isMockDriver => false;

  @override
  Future<void> toggleMockPro(bool enable) {
    throw UnsupportedError(
      'toggleMockPro is not supported in production RevenueCatBillingDriver. '
      'Use FakeBillingDriver in debug/profile environments instead.',
    );
  }

  Future<void> _ensureConfigured() {
    return _configureFuture ??= _doConfigure();
  }

  Future<void> _doConfigure() async {
    final key = _apiKeyOverride ?? RevenueCatConfig.apiKey;
    if (key.isNotEmpty) {
      await _delegate.configure(key);
    }
  }

  @override
  Future<bool> isPro() async {
    try {
      await _ensureConfigured();
      final customerInfo = await _delegate.getCustomerInfo();
      final isPro = customerInfo.entitlements.active.containsKey(_entitlementId);
      await _prefs.setIsProUser(isPro);
      return isPro;
    } catch (_) {
      // Offline fallback: rely on SQLite cache
      return _prefs.isProUser();
    }
  }

  @override
  Stream<bool> watchIsPro() {
    if (_customerInfoSubscription == null) {
      _customerInfoSubscription = _delegate.onCustomerInfoUpdated.listen((customerInfo) {
        final isPro = customerInfo.entitlements.active.containsKey(_entitlementId);
        _prefs.setIsProUser(isPro);
      });
      // Trigger background configuration and initial sync so app launch reflects remote state
      unawaited(_ensureConfigured().then((_) => isPro()).catchError((_) => false));
    }

    return _prefs.watchIsProUser();
  }

  @override
  Future<List<ProductPackage>> getAvailableProducts() async {
    try {
      await _ensureConfigured();
      final offerings = await _delegate.getOfferings();
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        return const [];
      }

      _packageCache.clear();
      final products = <ProductPackage>[];
      for (final pkg in current.availablePackages) {
        _packageCache[pkg.storeProduct.identifier] = pkg;
        _packageCache[pkg.identifier] = pkg;

        final period = _resolvePeriod(pkg);
        final hasTrial = pkg.storeProduct.introductoryPrice != null ||
            period == BillingPeriod.annual;

        products.add(
          ProductPackage(
            id: pkg.storeProduct.identifier,
            title: pkg.storeProduct.title.isNotEmpty
                ? pkg.storeProduct.title
                : _defaultTitleForPeriod(period),
            description: pkg.storeProduct.description,
            priceFormatted: pkg.storeProduct.priceString,
            priceNumeric: pkg.storeProduct.price,
            period: period,
            hasFreeTrial: hasTrial,
            discountPercentage: period == BillingPeriod.annual ? 50 : null,
          ),
        );
      }
      return products;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<domain.PurchaseResult> purchase(ProductPackage package) async {
    try {
      await _ensureConfigured();
      final rcPackage = _packageCache[package.id];
      if (rcPackage == null) {
        return const domain.PurchaseResult.error(
          'El paquete seleccionado no se encuentra disponible en la tienda.',
        );
      }

      final customerInfo = await _delegate.purchasePackage(rcPackage);
      final isPro = customerInfo.entitlements.active.containsKey(_entitlementId);
      if (isPro) {
        await _prefs.setIsProUser(true);
        return const domain.PurchaseResult.success();
      } else {
        return const domain.PurchaseResult.error(
          'La compra fue procesada pero la suscripción no figura activa.',
        );
      }
    } on PlatformException catch (e) {
      final errorCode = rc.PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == rc.PurchasesErrorCode.purchaseCancelledError) {
        return const domain.PurchaseResult.cancelled();
      }
      return domain.PurchaseResult.error(e.message ?? 'Error durante la compra');
    } catch (e) {
      return domain.PurchaseResult.error(e.toString());
    }
  }

  @override
  Future<domain.PurchaseResult> restorePurchases() async {
    try {
      await _ensureConfigured();
      final customerInfo = await _delegate.restorePurchases();
      final isPro = customerInfo.entitlements.active.containsKey(_entitlementId);

      if (isPro) {
        await _prefs.setIsProUser(true);
        return const domain.PurchaseResult.success();
      } else {
        // Do not revoke locally cached offline entitlement on failed restore.
        return const domain.PurchaseResult.error(
          'No se encontraron compras previas activas vinculadas a esta cuenta.',
        );
      }
    } on PlatformException catch (e) {
      return domain.PurchaseResult.error(
        e.message ?? 'No se pudo completar la restauración de compras',
      );
    } catch (e) {
      return domain.PurchaseResult.error(e.toString());
    }
  }

  @override
  void dispose() {
    _customerInfoSubscription?.cancel();
    _customerInfoSubscription = null;
    _delegate.dispose();
  }

  BillingPeriod _resolvePeriod(rc.Package pkg) {
    return switch (pkg.packageType) {
      rc.PackageType.annual => BillingPeriod.annual,
      rc.PackageType.monthly => BillingPeriod.monthly,
      rc.PackageType.lifetime => BillingPeriod.lifetime,
      _ => _inferPeriodFromId(pkg.identifier),
    };
  }

  BillingPeriod _inferPeriodFromId(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('annual') || lower.contains('year')) {
      return BillingPeriod.annual;
    }
    if (lower.contains('life')) {
      return BillingPeriod.lifetime;
    }
    return BillingPeriod.monthly;
  }

  String _defaultTitleForPeriod(BillingPeriod period) {
    return switch (period) {
      BillingPeriod.annual => 'Anual',
      BillingPeriod.monthly => 'Mensual',
      BillingPeriod.lifetime => 'De por vida',
    };
  }
}
