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

  Future<String?> getPlatformVersion() {
    return WindowsIapPlatform.instance.getPlatformVersion();
  }

  Future<StorePurchaseStatus?> makePurchase(String storeId) {
    return WindowsIapPlatform.instance.makePurchase(storeId);
  }

  void getProducts() {
    return WindowsIapPlatform.instance.getProducts();
  }

  Future<bool?> checkPurchase() {
    return WindowsIapPlatform.instance.checkPurchase();
  }
}
