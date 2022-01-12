import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qui_green/models/access_token_data.dart';
import 'package:qui_green/models/address_marker.dart';
import 'package:qui_green/models/base_response.dart';
import 'package:qui_green/models/change_package_status_request.dart';
import 'package:qui_green/models/delivery_package_request.dart';
import 'package:qui_green/models/device_info_model.dart';
import 'package:qui_green/models/generic_marker.dart';
import 'package:qui_green/models/login_request.dart';
import 'package:qui_green/models/pudo_marker.dart';
import 'package:qui_green/models/pudo_notification.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/models/pudo_package_event.dart';
import 'package:qui_green/models/pudo_profile.dart';
import 'package:qui_green/models/registration_request.dart';
import 'package:qui_green/models/user_profile.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:qui_green/resources/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'network_user.dart';

part 'network_user_pudo.dart';

part 'network_package.dart';

part 'network_notification.dart';

part 'network_pudo.dart';

class NetworkManager {
  AppConfig config;

  ConnectivityResult networkStatus = ConnectivityResult.mobile;
  String? _accessToken;
  final int _timeout = 30;
  int _refreshTokenRetryCounter = 0;
  final int _maxRetryCounter = 3;
  late ValueNotifier _networkActivity;
  late SharedPreferences _sharedPreferences;

  String _baseURL = "https://api-dev.quigreen.it";

  late Map<String, String> _headers;

  static final NetworkManager _inst = NetworkManager._internal(
    AppConfig(
        host: "https://api-dev.quigreen.it",
        isProd: false,
        appInfo: PackageInfo(
            appName: "",
            version: "1",
            packageName: "",
            buildNumber: "",
            buildSignature: "")),
  );

  static NetworkManager get instance {
    return NetworkManager._inst;
  }

  NetworkManager._internal(this.config);

  factory NetworkManager({required AppConfig config}) {
    _inst._networkActivity = ValueNotifier(false);
    _inst.config = config;
    _inst._baseURL = config.host;
    _inst._headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Application-Language': 'it',
      'User-Agent':
          'OpenPudo/${config.appInfo.version}#${config.appInfo.buildNumber}',
    };
    //SharedPreferences shared = await SharedPreferences.getInstance();
    _inst._sharedPreferences = config.sharedPreferencesInstance!;
    _inst._accessToken = _inst._sharedPreferences.getString('accessToken');
    Connectivity().onConnectivityChanged.listen(
      (result) {
        _inst.networkStatus = result;
      },
    );
    return _inst;
  }

  void _print(String text) {
    if (kDebugMode) {
      print(text);
    }
  }

  get networkActivity {
    return _networkActivity;
  }

  get baseURL {
    return _baseURL;
  }

  //
  //  Token handling
  //

  Future<dynamic> renewToken({required String accessToken}) async {
    Map<String, String> aRequest = {'accessToken': accessToken};

    var url = _baseURL + '/api/v1/auth/renew';
    var body = jsonEncode(aRequest);

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response =
          await post(Uri.parse(url), body: body, headers: _headers)
              .timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      if (baseResponse.returnCode == 0 && baseResponse.payload != null) {
        var accessTokenData = AccessTokenData.fromJson(baseResponse.payload);
        setAccessToken(accessTokenData.accessToken);
        _refreshTokenRetryCounter = 0;
        return baseResponse;
      } else {
        _refreshTokenRetryCounter++;
        throw ErrorDescription(
            'Error ${baseResponse.returnCode}: ${baseResponse.message}');
      }
    } on Error catch (e) {
      _refreshTokenRetryCounter++;
      _print('ERROR - checkUser: $e');
      return e;
    }
  }

  void setAccessToken(String? accessToken) {
    //TODO Shared
    if (accessToken != null) {
      _sharedPreferences.setString('accessToken', accessToken);
    } else {
      _sharedPreferences.remove('accessToken');
    }
    _accessToken = accessToken;
    _headers.remove('Authorization');
  }

  bool _handleTokenRefresh(
      OPBaseResponse baseResponse, Function? retryCallack) {
    if (baseResponse.returnCode == 3) {
      //try to refreshToken
      if (_refreshTokenRetryCounter > _maxRetryCounter) {
        throw ErrorDescription('Error maxRetryRefreshToken Exceeded');
      }
      if (_accessToken == null) {
        //needsLogin.value = true;
        return false;
      } else if (_accessToken != null) {
        renewToken(accessToken: _accessToken!).then((value) {
          retryCallack?.call();
        });
      } else {
        throw ErrorDescription(
            'Error: ${baseResponse.returnCode} - ${baseResponse.message}');
      }
      return true;
    }
    return false;
  }

  Future<dynamic> search(
      {double? lat, double? lon, required String text}) async {
    var queryString = "?text=$text";
    if (lat != null && lon != null) {
      queryString += "&lat=$lat&lon=$lon";
    }
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/map/search$queryString';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers)
          .timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<GenericMarker> pudos = <GenericMarker>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getAddresses(lat: lat, lon: lon, text: text)
              .catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            pudos.add(GenericMarker.fromGenericJson(aRow));
          }
          return pudos;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - search: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getAddresses(
      {double? lat, double? lon, required String text}) async {
    var queryString = "?text=$text";
    if (lat != null && lon != null) {
      queryString += "&lat=$lat&lon=$lon";
    }
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/map/search/addresses$queryString';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers)
          .timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<AddressMarker> pudos = <AddressMarker>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getAddresses(lat: lat, lon: lon, text: text)
              .catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            pudos.add(AddressMarker.fromJson(aRow));
          }
          return pudos;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - getAddress: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> photoUpload(File anImage, {bool? isPudo = false}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL +
        ((isPudo != null && isPudo == true)
            ? '/api/v1/pudos/me/profile-pic'
            : '/api/v1/users/me/profile-pic');
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
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      var json = jsonDecode(respStr);

      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(baseResponse, () {
        photoUpload(anImage, isPudo: isPudo)
            .catchError((onError) => throw onError);
      });

      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is Map) {
          if (isPudo == true) {
            return PudoProfile.fromJson(baseResponse.payload);
          } else {
            return UserProfile.fromJson(baseResponse.payload);
          }
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - photoupload: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setDeviceInfo({required DeviceInfoModel infoRequest}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/users/me/device-tokens';
    var body = jsonEncode(infoRequest.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response =
          await post(Uri.parse(url), body: body, headers: _headers)
              .timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          setDeviceInfo(infoRequest: infoRequest)
              .catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is Map) {
          return UserProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - setDeviceInfo: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }
}
