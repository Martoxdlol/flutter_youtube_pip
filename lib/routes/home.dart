import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:youtube_pip/components/AppBarSwitchableScaffold.dart';
import 'package:youtube_pip/components/OpenMenuButton.dart';
import 'package:youtube_pip/components/browser.dart';
import 'package:youtube_pip/routes/menu.dart';
import 'package:youtube_pip/settings.dart';
import 'package:youtube_pip/webServer.dart';

String? getVideoCodeFromUrl(String url) {
  // final regex = RegExp(
  // r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube(-nocookie)?\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$');
  final regex = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*');
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

    return TitleBarSwitchableScaffold(
        autoHideTitleBar: playingVideo.value,
        showBack: true,
        onBack: () {
          controller.goBack();
        },
        color: Colors.grey[160],
        content: BrowserView(
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
            }),
        floatingActionButton: ShowOnHover(
          showAlways: !playingVideo.value,
          child: OpenMenuButton(
            onPressed: () {
              Navigator.of(context).push(FluentPageRoute(builder: (context) {
                return Menu(webViewController: controller);
              }));
            },
          ),
        ));
  }
}
