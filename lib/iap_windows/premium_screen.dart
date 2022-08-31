// ignore_for_file: use_build_context_synchronously
import 'package:andesgroup_common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windows_iap/models/product.dart';
import 'package:windows_iap/windows_iap.dart';
import 'package:windows_iap/windows_iap_platform_interface.dart';

final iapWindowsProductsProvider = FutureProvider<List<Product>>((ref) async {
  return WindowsIap().getProducts();
});

class BuyScreenWindows extends ConsumerStatefulWidget {
  const BuyScreenWindows({this.title = 'Buy options', Key? key}) : super(key: key);
  final String title;

  @override
  ConsumerState<BuyScreenWindows> createState() => _BuyScreenWindowsState();
}

class _BuyScreenWindowsState extends ConsumerState<BuyScreenWindows> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.refresh(iapWindowsProductsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Consumer(builder: (context, ref, child) {
          final products = ref.watch(iapWindowsProductsProvider);
          return products.when(data: (data) {
            if (data.isEmpty) {
              return const Text('Upgrade options cannot be loaded at this time.');
            }
            return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                separatorBuilder: (context, index) {
                  return const Gap(16);
                },
                itemBuilder: (context, index) {
                  final i = data[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      title: Text(i.title ?? ''),
                      subtitle: Text(i.description ?? ''),
                      trailing: Text(i.price ?? ''),
                      onTap: () async {
                        final result =
                            await WindowsIapPlatform.instance.makePurchase(i.storeId ?? '');
                        if (result == StorePurchaseStatus.alreadyPurchased ||
                            result == StorePurchaseStatus.succeeded) {
                          showAlertDialog(context,
                              title: 'CONGRATULATIONS',
                              content: 'You have made a successful purchase.');
                        }
                      },
                    ),
                  );
                });
          }, error: (e, s) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(
                    "Error: ${e.toString()}",
                    style: TextStyles.t16SB,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }, loading: () {
            return const LoadingWidget();
          });
        }),
      ),
    );
  }
}
