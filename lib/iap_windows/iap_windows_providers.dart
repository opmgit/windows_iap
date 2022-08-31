import 'package:flutter/src/widgets/framework.dart';
import 'package:iap_interface/iap_interface.dart';
import 'package:windows_iap/iap_windows/premium_screen.dart';
import 'package:windows_iap/windows_iap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

final iapWindowsProvider = FutureProvider<List<Product>>((ref) async {
  return WindowsIap().getProducts();
});

class IapNotifierWindows extends IapNotifier {
  IapNotifierWindows(super.ref);

  final iap = WindowsIap();

  @override
  Future<bool> checkPurchase({String storeId = ''}) async {
    return await iap.checkPurchase(storeId: storeId);
  }

  @override
  Future<void> fetchProducts() async {
    await iap.getProducts();
  }

  @override
  Future<void> init() async {
    final havePremium = await checkPurchase();
    state = state.copyWith(havePremium: havePremium, mustShowNoteSubscription: true);
  }

  @override
  Future<void> makePurchase(String storeId) async {
    await iap.makePurchase(storeId);
  }

  @override
  Widget buyScreen({String title = 'Buy options'}) {
    return BuyScreenWindows(title: title);
  }
}
