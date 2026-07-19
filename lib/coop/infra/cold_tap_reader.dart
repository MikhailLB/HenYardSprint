import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

/// Reads the cold-start push URL written by SceneDelegate before the Flutter
/// engine attaches. The key MUST match SceneDelegate.launchRouteKey
/// (Swift side keeps the `flutter.` prefix).
class ColdTapReader {
  static const String _dartKey = 'hys_launch_route';

  static Future<String?> consume() async {
    if (!Platform.isIOS) return null;
    try {
      final preferences = await SharedPreferences.getInstance();
      final value = preferences.getString(_dartKey)?.trim();
      if (value == null || value.isEmpty) return null;
      await preferences.remove(_dartKey);
      return value;
    } catch (_) {
      return null;
    }
  }
}
