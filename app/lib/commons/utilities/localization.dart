/*
 OpenPUDO - PUDO and Micro-delivery software for Last Mile Collaboration
 Copyright (C) 2020-2022 LESS SRL - https://less.green

 This file is part of OpenPUDO software.

 OpenPUDO is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License version 3
 as published by the Copyright Owner.

 OpenPUDO is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License version 3 for more details.

 You should have received a copy of the GNU Affero General Public License
 version 3 published by the Copyright Owner along with OpenPUDO.  
 If not, see <https://github.com/lessgreen/OpenPUDO>.
*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qui_green/commons/extensions/trace_reflection.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationManager {
  Locale locale;
  late Map<String, dynamic> _dataSource;

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/locale.json');
  }

  LocalizationManager(this.locale);

  static Future<LocalizationManager> preloadLocale(Locale locale) async {
    try {
      //first of all, try to load updated content from file
      var localeFile = await LocalizationManager._localFile;
      var localeString = await localeFile.readAsString();
      var jsonLocale = jsonDecode(localeString);
      if (jsonLocale is Map<String, dynamic>) {
        var retObject = LocalizationManager(locale);
        retObject._dataSource = jsonLocale;
        return retObject;
      } else {
        throw ('UPDATED-LOCALE-NOT-FOUND');
      }
    } catch (e) {
      rootBundle.evict('resources/localization.json');
      var localeFile = await rootBundle.loadString('resources/localization.json');
      var jsonLocale = jsonDecode(localeFile);
      var retObject = LocalizationManager(locale);
      retObject._dataSource = jsonLocale as Map<String, dynamic>;
      return retObject;
    }
  }

  static updateLocalizationsFromNetwork() async {
    var newLocalizations = await NetworkManager.instance.getLocalizations();
    if (newLocalizations is Map<String, dynamic>) {
      var localeFile = await LocalizationManager._localFile;
      rootBundle.evict('resources/localization.json');
      var localeString = await rootBundle.loadString('resources/localization.json');
      var localeLanguages = jsonDecode(localeString) as Map<String, dynamic>;
      var updatedLanguages = pedanticDiff(localeLanguages, newLocalizations);
      var jsonEncoded = jsonEncode(updatedLanguages);
      await localeFile.writeAsString(jsonEncoded, flush: true);
    }
  }

  static Map<String, dynamic> pedanticDiff(Map<String, dynamic> oldDictionary, Map<String, dynamic> newDictionary) {
    var retDict = {...oldDictionary};
    retDict.forEach((key, oldLanguageDict) {
      if (newDictionary.containsKey(key)) {
        newDictionary[key]?.forEach((newKey, newTranslation) {
          if (newTranslation is Map<String, dynamic> && oldLanguageDict.containsKey(newKey)) {
            oldLanguageDict[newKey] = pedanticDiff(oldLanguageDict[newKey], newDictionary);
          } else {
            oldLanguageDict[newKey] = newTranslation;
          }
        });
      }
    });
    return retDict;
  }

  static LocalizationManager of(BuildContext context) {
    return Localizations.of<LocalizationManager>(context, LocalizationManager)!;
  }

  String localizedString(String page, String key) {
    var unescape = HtmlUnescape();
    return unescape.convert(_dataSource[locale.languageCode][page][key]);
  }

  String safeLocalizedString(String page, String key) {
    var unescape = HtmlUnescape();
    if (_dataSource.containsKey(locale.languageCode)) {
      dynamic tmpDataSource = _dataSource[locale.languageCode];
      if (tmpDataSource is Map && tmpDataSource.containsKey(page)) {
        dynamic tmpPage = tmpDataSource[page];
        if (tmpPage is Map && tmpPage.containsKey(key)) {
          return unescape.convert(_dataSource[locale.languageCode][page][key]);
        }
      }
    }
    return "!$page,$key!";
  }
}

extension LocalizedString on String {
  String localized(BuildContext context, [String? page]) {
    String buildPage;
    if (page == null) {
      buildPage = TraceReflection.stackFrame(2)?.first ?? 'general';
    } else {
      buildPage = page;
    }
    return LocalizationManager.of(context).safeLocalizedString(buildPage, this);
  }

  String localizedSubstitutingPlaceholder(BuildContext context, String value, String page) {
    var placeholdedString = LocalizationManager.of(context).safeLocalizedString(page, this);
    placeholdedString = placeholdedString.replaceAll('?????', value);
    return placeholdedString;
  }

  String localizedWithManager(LocalizationManager aManager, String page) {
    return aManager.safeLocalizedString(page, this);
  }
}

class LocalizationManagerDelegate extends LocalizationsDelegate<LocalizationManager> {
  final SharedPreferences _preferences;
  const LocalizationManagerDelegate(this._preferences);

  @override
  bool isSupported(Locale locale) => ['it', 'en'].contains(locale.languageCode);

  @override
  Future<LocalizationManager> load(Locale locale) {
    var languagePref = _preferences.getString('languagePref');
    if (languagePref != null) {
      locale = Locale(languagePref, languagePref.toUpperCase());
    }

    //in the meantime use the stored ones
    return LocalizationManager.preloadLocale(locale).then(
      (response) {
        return response;
      },
    );
  }

  @override
  bool shouldReload(LocalizationManagerDelegate old) => false;
}

class LocalLanguage extends ChangeNotifier {
  final SharedPreferences _preferences;

  LocalLanguage(this._preferences) {
    if (_preferences.getString('languagePref') == null) {
      _preferences.setString('languagePref', Intl.shortLocale(Intl.systemLocale));
    }
  }

  set locale(String newValue) {
    _preferences.setString('languagePref', newValue);
    notifyListeners();
  }

  Locale get currentLocale {
    return Locale(_preferences.getString('languagePref')!);
  }
}
