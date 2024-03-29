import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_youtube_pip/draggable_app_bar.dart';
import 'package:flutter_youtube_pip/web_server.dart';
import 'package:webview_windows/webview_windows.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class BrowserView extends StatefulWidget {
  final WebviewController controller;
  final Function onUrlChanged;
  const BrowserView({super.key, required this.onUrlChanged, required this.controller});

  @override
  State<BrowserView> createState() => _ExampleBrowser(onUrlChanged: onUrlChanged, controller: controller);
}

class _ExampleBrowser extends State<BrowserView> {
  final Function onUrlChanged;
  final WebviewController controller;
  bool _isWebviewSuspended = false;

  _ExampleBrowser({required this.onUrlChanged, required this.controller});

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      await controller.initialize();
      controller.url.listen((url) {
        onUrlChanged(url);
        // final uri = Uri.parse(url);
        // print(uri);
        // print(uri.host);
        // bool x = false;
        // if (uri.host == 'www.youtube.com' || uri.host == 'youtu.be') {
        //   if (!x) {
        //     //controller.loadUrl('https://www.youtube.com/embed/dQw4w9WgXcQ');
        //     x = true;
        //   }
        // }
      });

      await controller.setBackgroundColor(Colors.transparent);
      await controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      // Fake user agent to enable google signin
      await controller.setUserAgent('Mozilla/5.0 Chrome/99.0.4859.164 Safari/537.36');

      // final url = getServerUrl('VC5NaNsR7-8');
      await controller.loadUrl("https://www.youtube.com/");

      if (kDebugMode) {
        // await controller.openDevTools();
      }

      controller.loadingState.listen((event) {
        controller.executeScript(enableAutoPlayScriptContent());
      });

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => ContentDialog(
            title: Text('Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${e.code}'),
                Text('Message: ${e.message}'),
              ],
            ),
            actions: [
              Button(
                child: Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      });
    }
  }

  Widget compositeView() {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    if (!controller.value.isInitialized) {
      return SizedBox(
        width: width,
        height: height - DraggableAppBar.compactHeight,
        child: Center(
          child: ProgressRing(backgroundColor: Colors.grey[200]),
        ),
      );
    } else {
      return Webview(
        controller,
        permissionRequested: _onPermissionRequested,
        height: height,
        width: width,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[160],
      child: compositeView(),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => ContentDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          Button(
            onPressed: () => Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }
}
