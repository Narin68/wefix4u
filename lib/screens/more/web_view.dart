import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import '/globals.dart';
import '../widget.dart';

class MyWebView extends StatefulWidget {
  final String? url;
  final String? title;

  const MyWebView({Key? key, this.url, this.title}) : super(key: key);

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  int progress = 0;
  webview.WebViewController? _controller;

  bool _loading = true;
  final _key = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Txt(
          widget.title ?? "",
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            webview.WebView(
              key: _key,
              initialUrl: widget.url,
              javascriptMode: webview.JavascriptMode.unrestricted,
              onPageFinished: (finish) {
                setState(() {
                  _loading = false;
                });
              },
              onWebViewCreated: (c) async {
                // _controller?.loadUrl(
                // 'https://....../make-route',
                // headers: {"SB-app": "iphone"},
                // );

                _controller = c;

                await Future.delayed(Duration(milliseconds: 800));
                _controller?.runJavascript("showChat();");
                _controller
                    ?.runJavascript("callTranslate('${Globals.langCode}');");
              },
            ),
            _loading
                ? Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : Stack()
          ],
        ),
      ),
    );
  }
}
