import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:windows_iap/models/product.dart';
import 'package:windows_iap/models/store_license.dart';
import 'package:windows_iap/windows_iap.dart';
import 'package:windows_iap/windows_iap_method_channel.dart';
import 'package:windows_iap/windows_iap_platform_interface.dart';

class MockWindowsIapPlatform with MockPlatformInterfaceMixin implements WindowsIapPlatform {
  @override
  Stream<String> errorStream() {
    // TODO: implement errorStream
    throw UnimplementedError();
  }

  @override
  void getProducts() {
    // TODO: implement getProducts
  }

  @override
  Future<StorePurchaseStatus?> makePurchase(String storeId) {
    // TODO: implement makePurchase
    throw UnimplementedError();
  }

  @override
  Stream<List<Product>> productsStream() {
    // TODO: implement productsStream
    throw UnimplementedError();
  }

  @override
  Future<bool?> checkPurchase({required String storeId}) {
    // TODO: implement checkPurchase
    throw UnimplementedError();
  }

  @override
  Future<Map<String, StoreLicense>> getAddonLicenses() {
    // TODO: implement getAddonLicenses
    throw UnimplementedError();
  }
}

void main() {
  final WindowsIapPlatform initialPlatform = WindowsIapPlatform.instance;

  test('$MethodChannelWindowsIap is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWindowsIap>());
  });

  test('getPlatformVersion', () async {
    WindowsIap windowsIapPlugin = WindowsIap();
    MockWindowsIapPlatform fakePlatform = MockWindowsIapPlatform();
    WindowsIapPlatform.instance = fakePlatform;

    // expect(await windowsIapPlugin.getPlatformVersion(), '42');
  });
}
