import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_youtube_pip/constants.dart';
import 'package:flutter_youtube_pip/routes/home.dart';
import 'package:flutter_youtube_pip/settings.dart';
import 'package:flutter_youtube_pip/web_server.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  print("App start...");
  WidgetsFlutterBinding.ensureInitialized();
  print("Flutter bindings initialized");
  // Must add this line.
  await windowManager.ensureInitialized();
  print("Window manager initialized");

  WindowOptions windowOptions = const WindowOptions(
    size: initialSize,
    minimumSize: minSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  print("Window manager configured");
  runApp(const MyApp());
  print("App started");

  initWebServer().then((value) {
    print("Web server initialized on port $port");
    initWebServerStatusCheker();
  }).catchError((onError) {
    print("Cannot start web server");
  });

  appSettings = await SettingsData.read();

  if (appSettings.alwaysOnTop) await windowManager.setAlwaysOnTop(true);
  await windowManager.setOpacity(appSettings.opacity / 100);
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      color: Colors.transparent,
      title: 'Youtube PiP',
      theme: FluentThemeData.dark(),
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
