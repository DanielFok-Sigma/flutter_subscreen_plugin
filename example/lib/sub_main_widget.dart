import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_dualscreen_plugin/flutter_dualscreen_plugin.dart';

///副屏widget
class SubApp extends StatefulWidget {
  const SubApp({super.key});

  @override
  State<SubApp> createState() => _SubAppState();
}

class _SubAppState extends State<SubApp> {
  String receiveData = 'null';

  @override
  void initState() {
    super.initState();
    DualScreenPlugin.viceStream.listen((event) {
      setState(() {
        receiveData = event.arguments.toString();
      });
    });

    Future.delayed(const Duration(seconds: 5), sendMsgToMainScreen);
  }

  void sendMsgToMainScreen() {
    final randomData = Random().nextInt(100).toString();
    DualScreenPlugin.sendMsgToMainScreen("text", params: {"num": randomData});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('副屏'),
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('接收到的主屏数据为：$receiveData'),
                SizedBox(height: 50),
                TextButton(onPressed: sendMsgToMainScreen, child: Text('发送数据给主屏')),
              ],
            ),
          )),
    );
  }
}
