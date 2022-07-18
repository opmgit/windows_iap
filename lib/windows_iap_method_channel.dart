import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/product.dart';
import 'utils.dart';
import 'windows_iap.dart';
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
  Future<StorePurchaseStatus?> makePurchase(String storeId) async {
    final result = await methodChannel.invokeMethod<int>('makePurchase', {'storeId': storeId});
    if (result == null) {
      return null;
    }
    switch (result) {
      case 0:
        return StorePurchaseStatus.succeeded;
      case 1:
        return StorePurchaseStatus.alreadyPurchased;
      case 2:
        return StorePurchaseStatus.notPurchased;
      case 3:
        return StorePurchaseStatus.networkError;
      case 4:
        return StorePurchaseStatus.serverError;
    }
    return null;
  }

  @override
  Stream<String> errorStream() {
    return const EventChannel('windows_iap_event_error').receiveBroadcastStream().map((event) {
      if (event is String) {
        return event;
      } else {
        return "";
      }
    });
  }

  @override
  Stream<List<Product>> productsStream() {
    return const EventChannel('windows_iap_event_products').receiveBroadcastStream().map((event) {
      if (event is String) {
        return parseListNotNull(json: jsonDecode(event), fromJson: Product.fromJson);
      } else {
        return [];
      }
    });
  }

  @override
  void getProducts() {
    methodChannel.invokeMethod<int>('getProducts');
  }
}
