// ignore_for_file: use_build_context_synchronously
import 'package:andesgroup_common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iap_interface/iap_interface.dart';
import 'package:windows_iap/windows_iap.dart';

import 'iap_windows_providers.dart';

class BuyScreen extends ConsumerStatefulWidget {
  const BuyScreen({this.title = 'Buy options', this.showAppbar = true, Key? key}) : super(key: key);
  final String title;
  final bool showAppbar;

  @override
  ConsumerState<BuyScreen> createState() => _BuyScreenState();
}

const note =
    'Buy options cannot be loaded at this time, please try again.\nNote for review team: I can only submit add-ons when the application has been approved and available on the store, so before the application is available on the store, there will be no purchase option to be displayed.';

class _BuyScreenState extends ConsumerState<BuyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.refresh(iapWindowsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppbar
          ? AppBar(
              title: Text(widget.title),
            )
          : null,
      body: Center(
        child: Consumer(builder: (context, ref, child) {
          final products = ref.watch(iapWindowsProvider);
          return products.when(data: (data) {
            if (data.isEmpty) {
              return const Text(note, textAlign: TextAlign.center);
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
                        ref.read(iapProvider.notifier).makePurchase(i.storeId ?? '');
                      },
                    ),
                  );
                });
          }, error: (e, s) {
            if (e is PlatformException && e.code == '-2143330041') {
              return const Center(
                child: Text(note, textAlign: TextAlign.center),
              );
            }
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
