import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_youtube_pip/click_throught.dart';
import 'package:flutter_youtube_pip/components/app_scaffold.dart';
import 'package:flutter_youtube_pip/components/browser.dart';
import 'package:flutter_youtube_pip/draggable_app_bar.dart';
import 'package:flutter_youtube_pip/routes/menu.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_youtube_pip/settings.dart';
import 'package:flutter_youtube_pip/web_server.dart';
import 'package:flutter/material.dart' as material;

String? getVideoCodeFromUrl(String url) {
  // final regex = RegExp(
  // r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube(-nocookie)?\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$');
  final regex = RegExp(r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*');
  RegExpMatch? match = regex.firstMatch(url);
  if (match != null) {
    return match.group(7);
  }
  return null;
}

class HomePage extends HookWidget {
  HomePage({Key? key}) : super(key: key);

  final controller = WebviewController();

  Size? prevSize;

  @override
  Widget build(BuildContext context) {
    final playingVideo = useState(false);
    final playingCode = useState("");
    final ignoreMouseEvents = useState(false);

    return AppScaffold(
      autoHideTitleBar: playingVideo.value,
      showBack: true,
      onBack: () {
        controller.goBack();
      },
      color: Colors.grey[160],
      actions: [
        AppBarButton(
          height: DraggableAppBar.compactHeight,
          width: 50,
          onTap: () => Navigator.of(context).push(FluentPageRoute(
            builder: (context) => Menu(webViewController: controller),
          )),
          child: const Icon(material.Icons.menu),
        ),
        AppBarButton(
          height: DraggableAppBar.compactHeight,
          width: 50,
          child: const Icon(material.Icons.mouse_outlined),
          onTap: () {
            ignoreMouseEvents.value = true;
            windowManager.setIgnoreMouseEvents(true);
          },
        ),
      ],
      content: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: BrowserView(
              controller: controller,
              onUrlChanged: (String url) async {
                final code = getVideoCodeFromUrl(url);
                if (code != null && code != playingCode.value) {
                  playingCode.value = code;
                  await controller.goBack();
                  final playVideoUrl = getServerUrl(code);
                  print("Playing video, using url: $playVideoUrl");
                  await controller.loadUrl(playVideoUrl);
                }

                if (urlIsVideoPlayer(url)) {
                  playingVideo.value = true;
                  prevSize = await windowManager.getSize();

                  if (appSettings.autoResize != false) {
                    windowManager.setSize(const Size(16 * 25, 9 * 25));
                  }
                } else {
                  playingVideo.value = false;
                  if (prevSize != null) {
                    if (appSettings.autoResize != false) {
                      windowManager.setSize(prevSize!);
                    }
                    prevSize = null;
                  }
                }
              },
            ),
          ),
          if (ignoreMouseEvents.value)
            Positioned(
              bottom: 0,
              child: BottomBarMouseHoverHold(
                onAction: () {
                  ignoreMouseEvents.value = false;
                  windowManager.setIgnoreMouseEvents(false);
                  windowManager.setOpacity(appSettings.opacity / 100);
                },
              ),
            ),
        ],
      ),
    );
  }
}
