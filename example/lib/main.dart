import 'dart:async';

import 'package:andesgroup_common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _platformVersion = 'Unknown';
  final _windowsIapPlugin = WindowsIap();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _windowsIapPlugin.errorStream().listen((event) {
      print('error event is: $event');
    });
    _windowsIapPlugin.productsStream().listen((event) {
      event.forEach((element) {
        print(element.toJson());
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _windowsIapPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
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
                Text('Running on: $_platformVersion\n'),
                Gap(16),
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
              ],
            ),
          ),
        );
      }),
    );
  }
}
