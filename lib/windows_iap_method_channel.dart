import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'windows_iap_platform_interface.dart';

/// An implementation of [WindowsIapPlatform] that uses method channels.
class MethodChannelWindowsIap extends WindowsIapPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('windows_iap');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> makePurchase(String storeId) async {
    final result = await methodChannel.invokeMethod<bool>('makePurchase', {'storeId': storeId});
    return result;
  }
}
