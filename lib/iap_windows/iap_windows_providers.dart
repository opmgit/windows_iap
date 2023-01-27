import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iap_interface/iap_interface.dart';
import 'package:windows_iap/windows_iap.dart';

import '../models/product.dart';

final iapWindowsProvider = FutureProvider<List<Product>>((ref) async {
  return WindowsIap().getProducts();
});

class IapWindowsNotifier extends IapNotifier {
  IapWindowsNotifier(super.ref);

  final iap = WindowsIap();

  @override
  Future<bool> checkPurchase({String storeId = ''}) async {
    return await iap.checkPurchase(storeId: storeId);
  }

  @override
  Future<void> fetchProducts() async {
    super.ref.refresh(iapWindowsProvider);
  }

  @override
  Future<void> init() async {
    super.init();
    final havePremium = await checkPurchase();
    state = state.copyWith(havePremium: havePremium, mustShowNoteSubscription: true);
  }

  @override
  Future<void> makePurchase(String storeId) async {
    final result = await iap.makePurchase(storeId);
    if (result == StorePurchaseStatus.alreadyPurchased || result == StorePurchaseStatus.succeeded) {
      ref.read(iapProvider.notifier).buyDiamondsIfNeed(storeId);
      state = state.copyWith(message: IapMessage.from('Successful.', true));
    } else {
      state = state.copyWith(message: IapMessage.from('Fail.', true));
    }
  }

  @override
  Widget buyScreen({String title = 'Premium', bool showAppbar = true}) {
    return BuyScreen(title: title, showAppbar: showAppbar);
  }

  @override
  Future<void> restorePurchase() async {}
}
