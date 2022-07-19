import 'package:windows_iap/models/product.dart';

import 'windows_iap_platform_interface.dart';

enum StorePurchaseStatus {
  succeeded,
  alreadyPurchased,
  notPurchased,
  networkError,
  serverError,
}

class WindowsIap {
  Stream<String> errorStream() {
    return WindowsIapPlatform.instance.errorStream();
  }

  Stream<List<Product>> productsStream() {
    return WindowsIapPlatform.instance.productsStream();
  }

  Future<StorePurchaseStatus?> makePurchase(String storeId) {
    return WindowsIapPlatform.instance.makePurchase(storeId);
  }

  void getProducts() {
    return WindowsIapPlatform.instance.getProducts();
  }

  /// Check when user has current valid purchase
  ///
  /// - Add-On type: Subscription, Durable
  ///
  /// - Always return false if AppLicense has IsActive status = false.
  ///
  /// - if storeId is Not Empty:
  ///
  /// -- it will return true if Product(storeId) has IsActive status = true.
  ///
  /// -- return false if not.
  ///
  /// - if storeId is Empty:
  ///
  /// -- it will return true if any Add-On have IsActive status = true.
  ///
  /// -- return false if all Add-On have IsActive status = false.
  Future<bool?> checkPurchase({String storeId = ''}) {
    return WindowsIapPlatform.instance.checkPurchase(storeId: storeId);
  }
}
