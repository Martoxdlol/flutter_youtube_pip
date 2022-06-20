import 'package:shared_preferences/shared_preferences.dart';

class SettingsData {
  bool alwaysOnTop;
  bool autoResize;
  bool autoResumeBrowser;
  int opacity;
  SettingsData({
    required this.alwaysOnTop,
    required this.autoResize,
    required this.autoResumeBrowser,
    required this.opacity,
  });

  static Future<SettingsData> read() async {
    final prefs = await SharedPreferences.getInstance();

    return SettingsData(
      alwaysOnTop: prefs.getBool('allwaysOnTop') ?? true,
      autoResize: prefs.getBool('autoResize') ?? true,
      autoResumeBrowser: prefs.getBool('autoResumeBrowser') ?? true,
      opacity: prefs.getInt('opacity') ?? 100,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('allwaysOnTop', alwaysOnTop);
    prefs.setBool('autoResize', autoResize);
    prefs.setBool('autoResumeBrowser', autoResumeBrowser);
    prefs.setInt('opacity', opacity);
  }
}

late SettingsData appSettings;
