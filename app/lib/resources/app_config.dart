import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  final bool isProd;
  final PackageInfo appInfo;
  final SharedPreferences? sharedPreferencesInstance;
  final String host;
  final GlobalKey? globalKey;

  AppConfig({
    required this.isProd,
    required this.host,
    required this.appInfo,
    this.globalKey,
    this.sharedPreferencesInstance,
  });
}
