import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SettingsModel extends ChangeNotifier {
  String _themeMode = "auto";
  Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
  int _storeDistance = 3000;

  SettingsModel() {
    final window = SchedulerBinding.instance.window;
    window.onPlatformBrightnessChanged = () {
      if (_themeMode != "auto") return;
      brightness = window.platformBrightness;
      notifyListeners();
    };
  }

  String get theme => _themeMode;
  set theme(String newTheme) {
    _themeMode = newTheme;

    switch (newTheme) {
      case "light":
        brightness = Brightness.light;
        break;
      case "dark":
        brightness = Brightness.dark;
        break;
      default:
        brightness = SchedulerBinding.instance.window.platformBrightness;
    }

    notifyListeners();
  }

  int get storeDistance => _storeDistance;
  set storeDistance(int newDistance) {
    if (newDistance < 500 || newDistance > 10000) return;
    _storeDistance = newDistance;
  }
}
