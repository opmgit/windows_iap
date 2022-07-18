import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'windows_iap_method_channel.dart';

abstract class WindowsIapPlatform extends PlatformInterface {
  /// Constructs a WindowsIapPlatform.
  WindowsIapPlatform() : super(token: _token);

  static final Object _token = Object();

  static WindowsIapPlatform _instance = MethodChannelWindowsIap();

  /// The default instance of [WindowsIapPlatform] to use.
  ///
  /// Defaults to [MethodChannelWindowsIap].
  static WindowsIapPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WindowsIapPlatform] when
  /// they register themselves.
  static set instance(WindowsIapPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> makePurchase(String storeId) {
    throw UnimplementedError('makePurchase() has not been implemented.');
  }
}
