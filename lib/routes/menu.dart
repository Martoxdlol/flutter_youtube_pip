import 'dart:async';
import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_youtube_pip/components/app_scaffold.dart';
import 'package:flutter_youtube_pip/settings.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_youtube_pip/constants.dart';
import 'package:flutter_youtube_pip/routes/home.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_youtube_pip/web_server.dart';

class Menu extends HookWidget {
  WebviewController webViewController;
  Menu({super.key, required this.webViewController});

  Size? prevSize;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final clibBoardUrl = useState<String?>(null);
    final video = useState<YoutubeVideoInfo?>(null);

    final alwaysOnTop = useState(appSettings.alwaysOnTop);
    final autoResize = useState(appSettings.autoResize);
    final autoResumeBrowser = useState(appSettings.autoResumeBrowser);
    final opacity = useState(appSettings.opacity.toDouble());

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

      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        FlutterClipboard.paste().then((value) {
          if (getVideoCodeFromUrl(value) != null) {
            clibBoardUrl.value = value;
          }
        });
      });

      return () {
        timer.cancel();
        webViewController.resume();
      };
    }, []);

    useEffect(() {
      appSettings.alwaysOnTop = alwaysOnTop.value;
      appSettings.autoResize = autoResize.value;
      appSettings.autoResumeBrowser = autoResumeBrowser.value;
      appSettings.opacity = opacity.value.toInt();
      windowManager.setAlwaysOnTop(appSettings.alwaysOnTop);
      windowManager.setOpacity(opacity.value / 100);
      appSettings.save();
    }, [alwaysOnTop.value, autoResize.value, autoResumeBrowser.value, opacity.value]);

    final matechedUrlCode = getVideoCodeFromUrl(pastedUrl.value);
    final String? videoUrl = matechedUrlCode != null ? pastedUrl.value : clibBoardUrl.value;

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
      await webViewController.loadUrl(getServerUrl(getVideoCodeFromUrl(videoUrl) ?? ''));
    }

    return AppScaffold(
        color: const Color.fromARGB(195, 51, 51, 51),
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
            videoUrl != null
                ? ConfigField(
                    child: Button(
                    style: ButtonStyle(backgroundColor: ButtonState.all(Colors.grey[160])),
                    onPressed: (() {
                      playVideo();
                    }),
                    child: const Text(
                      "Play video",
                      style: TextStyle(color: Colors.white),
                    ),
                  ))
                : Container(),
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
            const Subtitle(title: 'Opacity'),
            ConfigField(
                child: Slider(
              onChanged: (value) => opacity.value = value,
              max: 100,
              value: opacity.value,
              label: 'Opacity',
              min: 10,
            )),
            const Subtitle(title: 'Pro tip'),
            ConfigField(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Click content behind the window",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  Row(
                    children: const [
                      Text(
                        "Change the window opacity, choose a video and click ",
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(material.Icons.mouse_outlined),
                      Text(
                        " on the title bar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                ],
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
          style: TextStyle(fontSize: (size != null) ? size : 30, color: Colors.white),
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
                padding: const EdgeInsets.all(8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    video.title,
                    style: const TextStyle(color: Colors.white, fontSize: 17, overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    video.author,
                    style: const TextStyle(color: Colors.white),
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
      padding: const EdgeInsets.only(left: 20, top: 5, bottom: 5, right: 20),
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
      placeholderStyle: const TextStyle(color: Color.fromARGB(100, 255, 255, 255)),
    ));
  }
}

class ToggleField extends StatelessWidget {
  final String label;
  final void Function(bool value)? onChange;
  final bool value;
  const ToggleField({super.key, required this.label, this.onChange, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ToggleSwitch(
          // style: ToggleSwitchThemeData(
          //     uncheckedDecoration: ButtonState.all(
          //         BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: Colors.white, width: 1)))),
          // thumb: Container(
          //   width: 13,
          //   height: 13,
          //   margin: const EdgeInsets.all(3),
          //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: Colors.white),
          // ),
          checked: value,
          onChanged: onChange,
          content: Text(label, style: const TextStyle(color: Colors.white)),
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
      {required this.title, required this.author, required this.description, required this.thumbnailUrl, required this.videoUrl});
}

Future<YoutubeVideoInfo?> fetchVideoInfo(String code) async {
  try {
    final response = await http.get(
        Uri.parse('https://noembed.com/embed?url=${Uri.encodeComponent('https://www.youtube.com/watch?v=${Uri.encodeComponent(code)}')}'));
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
