import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefProvider with ChangeNotifier {
  String path = '';
  bool loaded = false;

  PrefProvider() {}

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("path")) {
      path = prefs.getString("path")!;
    } else {
      path = '';
    }
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
}
