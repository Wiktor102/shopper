import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';

enum RecipesSort { alphabetically, byCategory, none }

class SettingsModel extends ChangeNotifier {
  String _themeMode = "auto";
  Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
  RecipesSort _recipesSort = RecipesSort.alphabetically;
  int _storeDistance = 3000;

  SettingsModel() {
    final window = SchedulerBinding.instance.window;

    window.onPlatformBrightnessChanged = () {
      if (_themeMode != "auto") return;
      brightness = window.platformBrightness;
      notifyListeners();
    };

    Hive.openBox("settings").then((Box box) {
      if (box.get("theme") != null) {
        theme = box.get("theme");
      }

      if (box.get("distance") != null) {
        storeDistance = box.get("distance");
      }

      if (box.get("recipesSort") != null) {
        recipesSort = box.get("recipesSort");
      }
    });
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

    Hive.box("settings").put("theme", newTheme);
    notifyListeners();
  }

  RecipesSort get recipesSort => _recipesSort;
  set recipesSort(RecipesSort newSetting) {
    _recipesSort = newSetting;
    Hive.box("settings").put("recipesSort", newSetting);
    notifyListeners();
  }

  int get storeDistance => _storeDistance;
  set storeDistance(int newDistance) {
    if (newDistance < 500 || newDistance > 10000) return;
    _storeDistance = newDistance;
    Hive.box("settings").put("distance", newDistance);
    notifyListeners();
  }
}
