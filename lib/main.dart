import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:youtube_pip/constants.dart';
import 'package:youtube_pip/routes/home.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:youtube_pip/settings.dart';
import 'package:youtube_pip/webServer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  await Window.initialize();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(360, 680),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp());

  if (Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..minSize = const Size(256, 144)
        ..size = initialSize
        ..alignment = Alignment.center
        ..show();
    });

    initWebServer();
  }

  appSettings = await SettingsData.read();

  final settings = appSettings;

  if (settings.alwaysOnTop) await windowManager.setAlwaysOnTop(true);

  if (settings.alwaysOnTop) await Window.setEffect(effect: WindowEffect.aero);
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      color: Colors.transparent,
      title: 'Youtube PiP',
      theme: ThemeData(),
      home: Routes(),
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
