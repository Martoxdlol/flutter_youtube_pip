import 'dart:async';
import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:youtube_pip/components/AppBarSwitchableScaffold.dart';
import 'package:youtube_pip/constants.dart';
import 'package:youtube_pip/routes/home.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_pip/settings.dart';

class Menu extends HookWidget {
  WebviewController webViewController;
  Menu({super.key, required this.webViewController});

  Size? prevSize;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final clibBoardUrl = useState<String?>(null);
    final video = useState<YoutubeVideoInfo?>(null);

    final alwaysOnTop = useState(true);
    final autoResize = useState(true);
    final autoResumeBrowser = useState(true);

    final pastedUrl = useState("");

    useEffect(() {
      () async {
        final size = await windowManager.getSize();
        if (size.width < 300 || size.height < 300) {
          prevSize = size;
          windowManager.setSize(initialSize);
        }
      }();

      if (appSettings.autoResumeBrowser) {
        webViewController.suspend();
      }

      alwaysOnTop.value = appSettings.alwaysOnTop;
      autoResize.value = appSettings.autoResize;
      autoResumeBrowser.value = appSettings.autoResumeBrowser;

      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        FlutterClipboard.paste().then((value) {
          if (getVideoCodeFromUrl(value) != null) {
            clibBoardUrl.value = value;
          }
        });
      });

      return () {
        timer.cancel();
        if (appSettings.autoResumeBrowser) {
          webViewController.resume();
        }
      };
    }, []);

    useEffect(() {
      appSettings.alwaysOnTop = alwaysOnTop.value;
      appSettings.autoResize = autoResize.value;
      appSettings.autoResumeBrowser = autoResumeBrowser.value;
      windowManager.setAlwaysOnTop(appSettings.alwaysOnTop);
      appSettings.save();
    }, [
      alwaysOnTop.value,
      autoResize.value,
      autoResumeBrowser.value,
    ]);

    final matechedUrlCode = getVideoCodeFromUrl(pastedUrl.value);
    final String? videoUrl =
        matechedUrlCode != null ? pastedUrl.value : clibBoardUrl.value;

    final String placeholder = clibBoardUrl.value ?? "YouTube video URL";

    final code = videoUrl != null ? getVideoCodeFromUrl(videoUrl) : null;

    useEffect(() {
      () async {
        if (code != null) {
          video.value = await fetchVideoInfo(code);
        }
      }();
    }, [videoUrl]);

    void playVideo() async {
      if (videoUrl == null) return;
      navigator.pop();
      webViewController.loadUrl(videoUrl);
    }

    return TitleBarSwitchableScaffold(
        showBack: true,
        onBack: () async {
          navigator.pop();
          if (prevSize != null) {
            if (!autoResize.value) return;
            await windowManager.setSize(prevSize!);
          }
        },
        content: ListView(
          children: [
            const Title(title: 'Paste video URL'),
            TextField(placheholder: placeholder),
            ConfigField(
                child: Button(
              style: ButtonStyle(
                  backgroundColor: ButtonState.all(Colors.grey[160])),
              onPressed: (() {
                playVideo();
              }),
              child: const Text(
                "Play video",
                style: TextStyle(color: Colors.white),
              ),
            )),
            video.value != null
                ? ConfigField(
                    child: VideoCard(
                    video: video.value!,
                    onClick: playVideo,
                  ))
                : Container(),
            const Title(title: 'Settings'),
            ConfigField(
              child: ToggleField(
                label: "Screen always on top",
                value: alwaysOnTop.value,
                onChange: (value) {
                  alwaysOnTop.value = value;
                },
              ),
            ),
            ConfigField(
              child: ToggleField(
                label: "Automatic resize on enter/exit video player",
                value: autoResize.value,
                onChange: (value) {
                  autoResize.value = value;
                },
              ),
            ),
            ConfigField(
              child: ToggleField(
                label: "Pause video when menu is opened",
                value: autoResumeBrowser.value,
                onChange: (value) {
                  autoResumeBrowser.value = value;
                },
              ),
            ),
          ],
        ));
  }
}

class Title extends StatelessWidget {
  final String title;
  final double? size;

  const Title({super.key, required this.title, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 22, top: 30, bottom: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: TextStyle(
              fontSize: (size != null) ? size : 30, color: Colors.white),
        )
      ]),
    );
  }
}

class VideoCard extends StatelessWidget {
  final YoutubeVideoInfo video;
  final Function onClick;

  const VideoCard({super.key, required this.video, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[160]),
          child: Row(
            children: [
              Image.network(
                video.thumbnailUrl,
                height: 80,
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        video.author,
                        style: TextStyle(color: Colors.white),
                      ),
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Subtitle extends StatelessWidget {
  final String title;
  final double? size;

  const Subtitle({super.key, required this.title, this.size});

  @override
  Widget build(BuildContext context) {
    return Title(title: title, size: size ?? 20);
  }
}

class ConfigField extends StatelessWidget {
  final Widget child;
  const ConfigField({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 5, bottom: 5, right: 20),
      child: child,
    );
  }
}

class TextField extends StatelessWidget {
  final void Function(String value)? onChanged;
  final String? placheholder;
  const TextField({super.key, this.onChanged, this.placheholder});

  @override
  Widget build(BuildContext context) {
    return ConfigField(
        child: TextBox(
      decoration: const BoxDecoration(color: Colors.black),
      style: const TextStyle(color: Colors.white),
      placeholder: placheholder,
      cursorColor: Colors.white,
      onChanged: onChanged,
      placeholderStyle: TextStyle(color: Color.fromARGB(100, 255, 255, 255)),
    ));
  }
}

class ToggleField extends StatelessWidget {
  final String label;
  final void Function(bool value)? onChange;
  final bool value;
  const ToggleField(
      {super.key, required this.label, this.onChange, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ToggleSwitch(
          style: ToggleSwitchThemeData(
              uncheckedDecoration: ButtonState.all(BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white, width: 1)))),
          thumb: Container(
            width: 13,
            height: 13,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99), color: Colors.white),
          ),
          checked: value,
          onChanged: onChange,
          content: Text(label, style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}

class YoutubeVideoInfo {
  final String title;
  final String author;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;

  const YoutubeVideoInfo(
      {required this.title,
      required this.author,
      required this.description,
      required this.thumbnailUrl,
      required this.videoUrl});
}

Future<YoutubeVideoInfo?> fetchVideoInfo(String code) async {
  try {
    final response = await http.get(Uri.parse(
        'https://noembed.com/embed?url=${Uri.encodeComponent('https://www.youtube.com/watch?v=${Uri.encodeComponent(code)}')}'));
    final rawVideoData = jsonDecode(response.body);
    final data = YoutubeVideoInfo(
      author: rawVideoData["author_name"],
      title: rawVideoData["title"],
      description: "",
      thumbnailUrl: rawVideoData["thumbnail_url"],
      videoUrl: rawVideoData["url"],
    );
    return data;
  } catch (e) {
    return null;
  }
}

// async function fetchVideoInfo(code) {
//     const r = await fetch('https://noembed.com/embed?url=' + encodeURIComponent('https://www.youtube.com/watch?v=' + encodeURIComponent(code)), {
//         method: 'GET',
//         headers: {
//             'Accept': 'application/json',
//             'Content-Type': 'application/json'
//         },
//     })
//     return await r.json()
// }