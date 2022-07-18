import 'package:flutter_test/flutter_test.dart';
import 'package:windows_iap/windows_iap.dart';
import 'package:windows_iap/windows_iap_platform_interface.dart';
import 'package:windows_iap/windows_iap_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWindowsIapPlatform 
    with MockPlatformInterfaceMixin
    implements WindowsIapPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
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
  
    expect(await windowsIapPlugin.getPlatformVersion(), '42');
  });
}
