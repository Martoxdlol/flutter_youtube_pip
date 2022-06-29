import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_pip/constants.dart';
import 'package:youtube_pip/routes/home.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:youtube_pip/settings.dart';
import 'package:youtube_pip/webServer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  await Window.initialize();

  // WindowOptions windowOptions = const WindowOptions(
  //     size: initialSize,
  //     center: true,
  //     backgroundColor: Colors.transparent,
  //     skipTaskbar: false,
  //     titleBarStyle: TitleBarStyle.hidden,
  //     title: 'Youtube Picture in Picture player',
  //     minimumSize: const Size(256, 144));

  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   // await windowManager.setAsFrameless();
  //   await windowManager.setHasShadow(true);
  //   // await windowManager.setResizable(true);
  //   // await windowManager.show();
  //   // await windowManager.focus();
  // });

  if (Platform.isWindows) {
    doWhenWindowReady(() async {
      appWindow
        ..minSize = const Size(256, 144)
        ..size = initialSize
        ..alignment = Alignment.center
        ..show();
    });
  }

  runApp(const MyApp());

  initWebServer().then((value) {
    initWebServerStatusCheker();
  }).catchError((onError) {
    print("FATAL, Cannot start web server");
  });

  appSettings = await SettingsData.read();

  final settings = appSettings;

  if (settings.alwaysOnTop) await windowManager.setAlwaysOnTop(true);
  await windowManager.setOpacity(settings.opacity / 100);

  await Window.setEffect(effect: WindowEffect.disabled);
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

  initWebServerStatusCheker();
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      color: Colors.transparent,
      title: 'Youtube PiP',
      theme: ThemeData(),
      home: const Routes(),
    );
  }
}

class Routes extends HookWidget {
  const Routes({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: HomePage(),
    );
  }
}
