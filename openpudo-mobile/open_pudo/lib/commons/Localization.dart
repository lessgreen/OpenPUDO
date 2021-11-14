//
//  Localization.dart
//  Alesea App
//
//  Created by Costantino Pistagna - Sofapps on 19/08/21
//  Copyright © 2021 - Sofapps - All rights reserved

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationManager {
  Locale locale;
  late Map<String, dynamic> _dataSource;

  LocalizationManager(this.locale);

  static Future<LocalizationManager> preloadLocale(Locale locale) async {
    rootBundle.evict('resources/localization.json');
    var localeFile = await rootBundle.loadString('resources/localization.json');
    var jsonLocale = jsonDecode(localeFile);
    var retObject = LocalizationManager(locale);
    retObject._dataSource = jsonLocale as Map<String, dynamic>;
    return retObject;
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
  String localized(BuildContext context, String page) {
    return LocalizationManager.of(context).safeLocalizedString(page, this);
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
  SharedPreferences _preferences;

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
