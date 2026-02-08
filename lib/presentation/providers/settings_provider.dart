import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kDarkMode = 'darkMode';
  static const _kCloudSync = 'cloudSyncEnabled';

  bool _isDarkMode = false;
  bool _cloudSyncEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get cloudSyncEnabled => _cloudSyncEnabled;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _isDarkMode = sp.getBool(_kDarkMode) ?? false;
    _cloudSyncEnabled = sp.getBool(_kCloudSync) ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    _isDarkMode = v;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kDarkMode, v);
  }

  Future<void> setCloudSync(bool v) async {
    _cloudSyncEnabled = v;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kCloudSync, v);
  }
}
