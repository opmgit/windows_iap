import 'package:flutter/src/widgets/framework.dart';
import 'package:iap_interface/iap_interface.dart';
import 'package:windows_iap/view/premium_screen.dart';
import 'package:windows_iap/windows_iap.dart';

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
    loadData();
  }

  @override
  Future<void> loadData() async {
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
