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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:qui_green/commons/utilities/print_helper.dart';
import 'package:qui_green/models/access_token_data.dart';
import 'package:qui_green/models/address_marker.dart';
import 'package:qui_green/models/base_response.dart';
import 'package:qui_green/models/change_package_status_request.dart';
import 'package:qui_green/models/delivery_package_request.dart';
import 'package:qui_green/models/device_info_model.dart';
import 'package:qui_green/models/geo_marker.dart';
import 'package:qui_green/models/login_request.dart';
import 'package:qui_green/models/map_search_addresses_request.dart';
import 'package:qui_green/models/map_search_request.dart';
import 'package:qui_green/models/openpudo_notification.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/pudo_summary.dart';
import 'package:qui_green/models/registration_pudo_model.dart';
import 'package:qui_green/models/registration_request.dart';
import 'package:qui_green/models/reward_option.dart';
import 'package:qui_green/models/support_request.dart';
import 'package:qui_green/models/update_pudo_request.dart';
import 'package:qui_green/models/user_preferences.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:qui_green/models/user_summary.dart';
import 'package:qui_green/resources/app_config.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'network_notification.dart';
part 'network_package.dart';
part 'network_pudo.dart';
part 'network_user.dart';
part 'network_user_pudo.dart';

mixin NetworkGeneral {
  late AppConfig config;
  String? _accessToken;
  final int _timeout = 30;
  int _refreshTokenRetryCounter = 0;
  final int _maxRetryCounter = 3;
  late ValueNotifier<bool> _networkActivity;
  late SharedPreferences _sharedPreferences;
  AccessTokenData? _accessTokenData;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  set isOnline(bool newValue) {
    _isOnline = newValue;
  }

  RetryOptions r = const RetryOptions(maxAttempts: 3);

  set sharedPreferences(SharedPreferences newVal) {
    _sharedPreferences = newVal;
  }

  set accessToken(String newVal) {
    _accessToken = newVal;
  }

  String get accessToken => _accessToken ?? "";

  String _baseURL = "https://api-dev.quigreen.it";

  late Map<String, String> _headers;

  set headers(Map<String, String> newVal) {
    _headers = newVal;
  }

  ValueNotifier<bool> get networkActivity {
    return _networkActivity;
  }

  set networkActivity(ValueNotifier<bool> newVal) {
    _networkActivity = newVal;
  }

  get baseURL {
    return _baseURL;
  }

  set baseURL(newVal) {
    _baseURL = newVal;
  }

  //
  //  Token handling
  //

  Future<dynamic> renewToken({required String accessToken}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v2/auth/renew';
    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => post(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      if (baseResponse.returnCode == 0 && baseResponse.payload != null) {
        var accessTokenData = AccessTokenData.fromJson(baseResponse.payload);
        setAccessTokenData(accessTokenData);
        setAccessToken(accessTokenData.accessToken);
        _refreshTokenRetryCounter = 0;
        return baseResponse;
      } else {
        _refreshTokenRetryCounter++;
        throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
      }
    } catch (e) {
      _refreshTokenRetryCounter++;
      safePrint('ERROR - checkUser: $e');
      _networkActivity.value = false;
      return e;
    }
  }

  void setAccessTokenData(AccessTokenData newVal) {
    _accessTokenData = newVal;
  }

  get accessTokenAccess => _accessTokenData == null ? "none" : _accessTokenData!.accessProfile;

  void setAccessToken(String? accessToken) {
    if (accessToken != null) {
      _sharedPreferences.setString('accessToken', accessToken);
    } else {
      _sharedPreferences.remove('accessToken');
    }
    _accessToken = accessToken;
    _headers.remove('Authorization');
  }

  void removeAccessToken() {
    _sharedPreferences.remove('accessToken');
  }

  bool _handleTokenRefresh(OPBaseResponse baseResponse, Function? retryCallack) {
    if (baseResponse.returnCode == 401) {
      //try to refreshToken
      if (_refreshTokenRetryCounter > _maxRetryCounter) {
        throw ErrorDescription('Error maxRetryRefreshToken Exceeded');
      }
      if (_accessToken == null) {
        return false;
      } else if (_accessToken != null) {
        renewToken(accessToken: _accessToken!).then((value) {
          retryCallack?.call();
        });
      } else {
        throw ErrorDescription('Error: ${baseResponse.returnCode} - ${baseResponse.message}');
      }
      return true;
    }
    return false;
  }

  Future<dynamic> getAddresses({double? lat, double? lon, required String text}) async {
    var queryString = "?text=$text";
    if (lat != null && lon != null) {
      queryString += "&lat=$lat&lon=$lon";
    }
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v2/map/search/address$queryString';

    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<GeoMarker> pudos = <GeoMarker>[];
      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getAddresses(lat: lat, lon: lon, text: text).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            pudos.add(GeoMarker.fromJson(aRow));
          }
          return pudos;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getAddress: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getGeoMarkers({double? lat, double? lon, required String text}) async {
    var queryString = "?text=$text";
    if (lat != null && lon != null) {
      queryString += "&lat=$lat&lon=$lon";
    }
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v2/map/search/$queryString';

    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<GeoMarker> pudos = <GeoMarker>[];
      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getAddresses(lat: lat, lon: lon, text: text).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            pudos.add(GeoMarker.fromJson(aRow));
          }
          return pudos;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getAddress: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> photoUpload(File anImage, {bool? isPudo = false}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + ((isPudo != null && isPudo == true) ? '/api/v2/pudo/me/picture' : '/api/v2/user/me/picture');
    var uri = Uri.parse(url);

    // create multipart request
    var request = MultipartRequest("PUT", uri);
    var multipartFileSign = MultipartFile(
      'attachment',
      anImage.readAsBytes().asStream(),
      anImage.lengthSync(),
      filename: basename(anImage.path),
      contentType: MediaType("image", "jpeg"),
    );

    request.files.add(multipartFileSign);
    _headers.forEach((k, v) {
      request.headers[k] = v;
    });

    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      var json = jsonDecode(respStr);

      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(baseResponse, () {
        photoUpload(anImage, isPudo: isPudo).catchError((onError) => throw onError);
      });
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0) {
          return null;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - photoupload: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> setDeviceInfo({required DeviceInfoModel infoRequest}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v2/user/me/device-tokens';
    var body = jsonEncode(infoRequest.toJson());
    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          setDeviceInfo(infoRequest: infoRequest).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0) {
          return true;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - setDeviceInfo: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getLocalizations() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v2/file/localization';

    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getLocalizations().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return baseResponse.payload;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getLocalizations: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }
}
