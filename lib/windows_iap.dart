import 'windows_iap_platform_interface.dart';

class WindowsIap {
  Future<String?> getPlatformVersion() {
    return WindowsIapPlatform.instance.getPlatformVersion();
  }

  Future<bool?> makePurchase(String storeId) {
    return WindowsIapPlatform.instance.makePurchase(storeId);
  }
}
