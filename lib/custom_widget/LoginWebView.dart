import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/custom_widget/Fail.dart';
import 'package:myapp/custom_widget/LoginSuccess.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  final initUrl = 'https://giggleforest.com:4588';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  Widget _buildLoadingBar() {
    if (isLoading) {
      return Container(
          color: const Color(0x88808080),
          child: const Center(child: CircularProgressIndicator()));
    } else {
      return Container();
    }
  }

  Map<String, String> _makeMapFromSearchQuery(String searchQuery) {
    final Map<String, String> query = Map();
    final splitedByAnd =
        searchQuery.substring(1, searchQuery.length).split('&');
    for (int i = 0; i < splitedByAnd.length; i++) {
      final splitedByEqual = splitedByAnd[i].split('=');
      if (splitedByEqual.length > 1) {
        query[splitedByEqual[0]] = splitedByEqual[1];
      }
    }
    return query;
  }

  bool _isLoginSuccess(Map<String, String> queryMap) {
    if (queryMap.containsKey('code')) {
      return true;
    }
    return false;
  }

  void _goToFail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginFail()),
    );
  }

  void _goToSuccess(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          code: code,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        WebView(
          zoomEnabled: false,
          initialUrl: widget.initUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (controller) {
            _controller = controller;
            _controller.clearCache();
          },
          onProgress: (val) {
            setState(() => {isLoading = true});
          },
          onPageFinished: (val) {
            setState(() => {isLoading = false});
          },
          javascriptChannels: <JavascriptChannel>{
            JavascriptChannel(
              name: 'AppMsgChannel',
              onMessageReceived: (JavascriptMessage message) {
                _controller.loadUrl(widget.initUrl);
                final queryMap = _makeMapFromSearchQuery(message.message);
                if (_isLoginSuccess(queryMap)) {
                  _goToSuccess(queryMap['code']!);
                } else {
                  _goToFail();
                }
              },
            ),
          },
        ),
        _buildLoadingBar(),
      ],
    );
  }

  // Future.value false -> can not goback
  Future<bool> _willPopHandler() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopHandler,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: _buildBody(),
      ),
    );
  }
}
