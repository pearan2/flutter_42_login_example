import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: WebViewExample(),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  dynamic controller;
  bool isWeb = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  void _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('assets/index.html');
    controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  Widget _buildBody() {
    if (isWeb) {
      return WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) async {
          webViewController.clearCache();
          controller = webViewController;
          _loadHtmlFromAssets();
        },
        javascriptChannels: <JavascriptChannel>{
          JavascriptChannel(
              name: 'AppMsgChannel',
              onMessageReceived: (JavascriptMessage message) {
                setState(() => {isWeb = false});
              }),
        },
      );
    } else {
      return Text("logined");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}
