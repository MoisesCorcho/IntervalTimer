import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Abstract delegate separating [RevenueCatBillingDriver] from the static [Purchases] API.
/// Enables deterministic unit testing without invoking native platform channels.
abstract class PurchasesDelegate {
  Future<void> configure(String apiKey);
  Future<CustomerInfo> getCustomerInfo();
  Stream<CustomerInfo> get onCustomerInfoUpdated;
  Future<Offerings> getOfferings();
  Future<CustomerInfo> purchasePackage(Package package);
  Future<CustomerInfo> restorePurchases();
  void dispose();
}

/// Default production implementation delegating directly to the native [Purchases] SDK.
class RevenueCatPurchasesDelegate implements PurchasesDelegate {
  RevenueCatPurchasesDelegate();

  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  CustomerInfoUpdateListener? _updateListener;

  @override
  Future<void> configure(String apiKey) async {
    await Purchases.configure(PurchasesConfiguration(apiKey));
    if (_updateListener == null) {
      _updateListener = (customerInfo) {
        if (!_customerInfoController.isClosed) {
          _customerInfoController.add(customerInfo);
        }
      };
      Purchases.addCustomerInfoUpdateListener(_updateListener!);
    }
  }

  @override
  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  @override
  Stream<CustomerInfo> get onCustomerInfoUpdated => _customerInfoController.stream;

  @override
  Future<Offerings> getOfferings() => Purchases.getOfferings();

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  @override
  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  @override
  void dispose() {
    if (_updateListener != null) {
      Purchases.removeCustomerInfoUpdateListener(_updateListener!);
      _updateListener = null;
    }
    _customerInfoController.close();
  }
}
