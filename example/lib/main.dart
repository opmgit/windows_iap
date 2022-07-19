import 'package:andesgroup_common/common.dart';
import 'package:flutter/material.dart';
import 'package:windows_iap/windows_iap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _windowsIapPlugin = WindowsIap();

  @override
  void initState() {
    super.initState();
    _windowsIapPlugin.errorStream().listen((event) {
      print('error event is: $event');
    });
    _windowsIapPlugin.productsStream().listen((event) {
      event.forEach((element) {
        print(element.toJson());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      final result = await _windowsIapPlugin.checkPurchase();
                      showAlertDialog(context, content: 'checkPurchase: $result');
                    },
                    child: Text('checkPurchase')),
                Gap(16),
                ElevatedButton(
                    onPressed: () async {
                      final result = await _windowsIapPlugin.makePurchase('hihi');
                      print('result is $result');
                    },
                    child: Text('makePurchase')),
                Gap(16),
                ElevatedButton(
                    onPressed: () async {
                      _windowsIapPlugin.getProducts();
                    },
                    child: Text('getProducts')),
                Gap(16),
                ElevatedButton(
                    onPressed: () async {
                      final result = await _windowsIapPlugin.getAddonLicenses();
                      print('licenses: $result');
                    },
                    child: Text('getAddonLicenses')),
              ],
            ),
          ),
        );
      }),
    );
  }
}
