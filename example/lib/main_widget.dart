// ignore_for_file: missing_return

import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dualscreen_plugin/flutter_dualscreen_plugin.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  String receiveData = 'null';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkOverlayPermission();
    });
    DualScreenPlugin.mainStream.listen((event) {
      setState(() {
        receiveData = event.arguments.toString();
      });
    });
  }

  ///判读是否需要 overlay 窗口权限
  void checkOverlayPermission() async {
    final isMultipleScreen = await DualScreenPlugin.isMultipleScreen;
    dev.log("是否支持副屏 ： $isMultipleScreen");

    if (isMultipleScreen) {
      final hasOverlayPermission = await DualScreenPlugin.checkOverlayPermission;
      dev.log("overlay 权限为 ： $hasOverlayPermission");
      if (!hasOverlayPermission) {
        _showCheckOverlayPermission();
      }
    }
  }

  ///弹窗询问是否进行 overlay 权限申请
  void _showCheckOverlayPermission() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('已检测到副屏，将副屏设置为持久窗口需开启权限，是否设置'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('否'),
            ),
            TextButton(
              onPressed: () async {
                final hasPermission = await DualScreenPlugin.checkOverlayPermission;
                if (!hasPermission) {
                  DualScreenPlugin.requestOverlayPermission();
                } else {
                  DualScreenPlugin.doubleScreenShow();
                  Navigator.of(context).pop();
                }
              },
              child: Text('是'),
            ),
          ],
        );
      },
    );
  }

  void sendMsgToSubScreen() {
    DualScreenPlugin.isMultipleScreen.then((isMultipleScreen) {
      if (isMultipleScreen) {
        final randomData = Random().nextInt(100).toString();
        DualScreenPlugin.sendMsgToViceScreen(
          "text",
          params: {"num": randomData},
        );
      } else {
        _messangerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('未查询到可用副屏'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('主屏'),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('接收到的副屏数据为：$receiveData'),
                SizedBox(height: 30),
                TextButton(
                  onPressed: sendMsgToSubScreen,
                  child: Text('发送数据给副屏'),
                ),
                SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    DualScreenPlugin.doubleScreenShow();
                  },
                  child: Text('开启副屏'),
                ),
                SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    DualScreenPlugin.doubleScreenCancel();
                  },
                  child: Text('关闭副屏'),
                ),
              ],
            ),
          )),
    );
  }
}
