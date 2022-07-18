import 'windows_iap_platform_interface.dart';

enum StorePurchaseStatus {
  succeeded,
  alreadyPurchased,
  notPurchased,
  networkError,
  serverError,
}

class WindowsIap {
  Future<String?> getPlatformVersion() {
    return WindowsIapPlatform.instance.getPlatformVersion();
  }

  Future<StorePurchaseStatus?> makePurchase(String storeId) {
    return WindowsIapPlatform.instance.makePurchase(storeId);
  }
}
