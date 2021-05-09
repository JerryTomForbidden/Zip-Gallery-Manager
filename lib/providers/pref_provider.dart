import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefProvider with ChangeNotifier {
  String path = '';
  bool scanFolders = false;
  bool onlyArchiveFiles = true;
  bool loaded = false;

  PrefProvider() {}

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("path")) {
      path = prefs.getString("path")!;
    } else {
      path = '';
    }

    if (prefs.containsKey("scanFolders")) {
      scanFolders = prefs.getBool("scanFolders")!;
    } else
      scanFolders = false;

    if (prefs.containsKey("onlyArchiveFiles")) {
      onlyArchiveFiles = prefs.getBool("onlyArchiveFiles")!;
    } else
      onlyArchiveFiles = true;

    loaded = true;

    notifyListeners();
    return;
  }

  Future<void> setPath(String _path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('path', _path);
    path = _path;
    loaded = false;
    notifyListeners();
  }

  Future<void> setScanFolders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scanFolders', enabled);
    scanFolders = enabled;
    //TODO whyy?
    loaded = false;
    notifyListeners();
  }

  Future<void> setOnlyArchiveFiles(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onlyArchiveFiles', enabled);
    onlyArchiveFiles = enabled;
    //TODO whyy?
    loaded = false;
    notifyListeners();
  }
}
