//
//  NetworkManager.dart
//  OpenPudo
//
//  Created by Costantino Pistagna on 19/05/2021.
//  Copyright © 2021 Sofapps. All rights reserved.
//

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:open_pudo/main.dart';
import 'package:open_pudo/models/access_token_data.dart';
import 'package:open_pudo/models/address_marker.dart';
import 'package:open_pudo/models/base_response.dart';
import 'package:open_pudo/models/change_package_status_request.dart';
import 'package:open_pudo/models/delivery_package_request.dart';
import 'package:open_pudo/models/device_info_model.dart';
import 'package:open_pudo/models/generic_marker.dart';
import 'package:open_pudo/models/login_request.dart';
import 'package:open_pudo/models/pudo_marker.dart';
import 'package:open_pudo/models/pudo_notification.dart';
import 'package:open_pudo/models/pudo_package.dart';
import 'package:open_pudo/models/pudo_package_event.dart';
import 'package:open_pudo/models/pudo_profile.dart';
import 'package:open_pudo/models/registration_request.dart';
import 'package:open_pudo/models/user_profile.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

class NetworkManager {
  ConnectivityResult networkStatus = ConnectivityResult.mobile;
  String? _accesstoken;
  int _timeout = 30;
  int _refreshTokenRetryCounter = 0;
  int _maxRetryCounter = 3;
  ValueNotifier _networkActivity = ValueNotifier(false);

  String _baseURL = "https://api-dev.quigreen.it";

  Map<String, String> _headers = {
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'Application-Language': 'it',
    'User-Agent': 'OpenPudo/${packageInfo.version}#${packageInfo.buildNumber}',
  };

  static final NetworkManager _shared = NetworkManager._internal();

  factory NetworkManager() {
    return _shared;
  }

  NetworkManager._internal() {
    //init method
    _accesstoken = sharedPreferences?.getString('accessToken');

    Connectivity().onConnectivityChanged.listen(
      (result) {
        NetworkManager().networkStatus = result;
      },
    );
  }

  get networkActivity {
    return _networkActivity;
  }

  get baseURL {
    return _baseURL;
  }

  setAccessToken(String? accessToken) {
    if (accessToken != null) {
      sharedPreferences?.setString('accessToken', accessToken);
    } else {
      sharedPreferences?.remove('accessToken');
    }
    _accesstoken = accessToken;
    _headers.remove('Authorization');
  }

  bool _handleTokenRefresh(OPBaseResponse baseResponse, Function? retryCallack) {
    if (baseResponse.returnCode == 3) {
      //try to refreshToken
      if (_refreshTokenRetryCounter > _maxRetryCounter) {
        throw ErrorDescription('Error maxRetryRefreshToken Exceeded');
      }
      if (_accesstoken == null) {
        needsLogin.value = true;
        return false;
      } else if (_accesstoken != null) {
        renewToken(accessToken: _accesstoken!).then((value) {
          retryCallack?.call();
        });
      } else {
        throw ErrorDescription('Error: ${baseResponse.returnCode} - ${baseResponse.message}');
      }
      return true;
    }
    return false;
  }

  Future<dynamic> registerPudo({
    required String password,
    required String firstName,
    required String lastName,
    required String businessName,
    String? email,
    String? phoneNumber,
    String? username,
    String? vat,
    String? contactNotes,
    String? businessPhone,
  }) async {
    PudoProfile pudoProfile = PudoProfile(
      businessName: businessName,
      contactNotes: contactNotes,
      vat: vat,
      phoneNumber: businessPhone,
    );
    UserProfile userProfile = UserProfile(
      firstName: firstName,
      lastName: lastName,
    );
    RegistrationRequest aRequest = RegistrationRequest(
      password: password,
      user: userProfile,
      pudo: pudoProfile,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
    );

    var url = _baseURL + '/api/v1/auth/register';
    var body = jsonEncode(aRequest.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      return baseResponse;
    } on Error catch (e) {
      print('ERROR - registerPudo: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> registerUser({required String password, required String firstName, required String lastName, String? email, String? phoneNumber, String? username, String? ssn}) async {
    UserProfile userProfile = UserProfile(
      firstName: firstName,
      lastName: lastName,
      ssn: ssn,
    );
    RegistrationRequest aRequest = RegistrationRequest(
      password: password,
      user: userProfile,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
    );

    var url = _baseURL + '/api/v1/auth/register';
    var body = jsonEncode(aRequest.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      return baseResponse;
    } on Error catch (e) {
      print('ERROR - registerUser: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> login({required String login, required String password}) async {
    LoginRequest aRequest = LoginRequest(
      login: login,
      password: password,
    );

    var url = _baseURL + '/api/v1/auth/login';
    var body = jsonEncode(aRequest.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      if (baseResponse.returnCode == 0 && baseResponse.payload != null) {
        var accessTokenData = AccessTokenData.fromJson(baseResponse.payload);
        setAccessToken(accessTokenData.accessToken);
      }
      return baseResponse;
    } on Error catch (e) {
      print('ERROR - login: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> renewToken({required String accessToken}) async {
    Map<String, String> aRequest = {'accessToken': accessToken};

    var url = _baseURL + '/api/v1/auth/renew';
    var body = jsonEncode(aRequest);

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      if (baseResponse.returnCode == 0 && baseResponse.payload != null) {
        var accessTokenData = AccessTokenData.fromJson(baseResponse.payload);
        setAccessToken(accessTokenData.accessToken);
        _refreshTokenRetryCounter = 0;
        return baseResponse;
      } else {
        _refreshTokenRetryCounter++;
        throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
      }
    } on Error catch (e) {
      _refreshTokenRetryCounter++;
      print('ERROR - checkUser: $e');
      return e;
    }
  }

  Future<dynamic> getPudos({double? lat, double? lon, int? zoom, String? text}) async {
    var queryString = "";
    if (lat != null && lon != null && zoom != null) {
      queryString = "?lat=$lat&lon=$lon&zoom=$zoom";
    } else if (text != null) {
      queryString = "?text=$text";
    }
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/map/pudos$queryString';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<PudoMarker> pudos = <PudoMarker>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getPudos(lat: lat, lon: lon, zoom: zoom).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            pudos.add(PudoMarker.fromJson(aRow));
          }
          return pudos;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getPudos: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> search({double? lat, double? lon, required String text}) async {
    var queryString = "?text=$text";
    if (lat != null && lon != null) {
      queryString += "&lat=$lat&lon=$lon";
    }
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/map/search$queryString';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<GenericMarker> pudos = <GenericMarker>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getAddresses(lat: lat, lon: lon, text: text).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            pudos.add(GenericMarker.fromGenericJson(aRow));
          }
          return pudos;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - search: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getAddresses({double? lat, double? lon, required String text}) async {
    var queryString = "?text=$text";
    if (lat != null && lon != null) {
      queryString += "&lat=$lat&lon=$lon";
    }
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/map/search/addresses$queryString';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<AddressMarker> pudos = <AddressMarker>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getAddresses(lat: lat, lon: lon, text: text).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            pudos.add(AddressMarker.fromJson(aRow));
          }
          return pudos;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getAddress: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getPudoDetails({required String pudoId}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/pudos/$pudoId';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getPudoDetails(pudoId: pudoId).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getPudoDetails: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyPudoProfile() async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/pudos/me';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getMyPudoProfile().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getMyPudoProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setMyPudoProfile(PudoProfile profile) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/pudos/me';
    var body = jsonEncode(profile.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await put(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          setMyPudoProfile(profile).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - setMyPudoProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setMyPudoAddress(AddressMarker address) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/pudos/me/address';
    var body = jsonEncode(address.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await put(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          setMyPudoAddress(address).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - setMyPudoAddress: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyPudoUsers() async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/pudos/me/users';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<UserProfile> myUsers = <UserProfile>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getMyPudoUsers().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myUsers.add(UserProfile.fromJson(aRow));
          }
          return myUsers;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getMyPudoUsers: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyProfile() async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/users/me';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getMyProfile().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return UserProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getMyProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setMyProfile(UserProfile profile) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/users/me';
    var body = jsonEncode(profile.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await put(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          setMyProfile(profile).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return UserProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - setMyProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyPudos() async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/users/me/pudos';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<PudoProfile> myPudos = <PudoProfile>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getMyPudos().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myPudos.add(PudoProfile.fromJson(aRow));
          }
          return myPudos;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getMyPudos: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> addPudoFavorite(String pudoId) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/users/me/pudos/$pudoId';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await put(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<PudoProfile> myPudos = <PudoProfile>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          addPudoFavorite(pudoId).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myPudos.add(PudoProfile.fromJson(aRow));
          }
          return myPudos;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - addPudoFavorite: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> removePudoFavorite(String pudoId) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/users/me/pudos/$pudoId';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await delete(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<PudoProfile> myPudos = <PudoProfile>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          removePudoFavorite(pudoId).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myPudos.add(PudoProfile.fromJson(aRow));
          }
          return myPudos;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - removePudoFavorite: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getPublicProfile(String userId) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/users/$userId';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getPublicProfile(userId).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return UserProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getPublicProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<Uint8List> profilePic(String id) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }
    var url = _baseURL + '/api/v1/file/$id';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw ErrorDescription('Error ${response.statusCode}: ${response.body}');
    } on Error catch (e) {
      print('ERROR - deleteProfilePic: $e');
      _refreshTokenRetryCounter = 0;
      var data = await rootBundle.load('assets/placeholderImage.jpg');
      return data.buffer.asUint8List();
    }
  }

  Future<dynamic> photoupload(File anImage, {bool? isPudo = false}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + ((isPudo != null && isPudo == true) ? '/api/v1/pudos/me/profile-pic' : '/api/v1/users/me/profile-pic');
    var uri = Uri.parse(url);

    // create multipart request
    var request = MultipartRequest("PUT", uri);
    var multipartFileSign = new MultipartFile(
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
        photoupload(anImage, isPudo: isPudo).catchError((onError) => throw onError);
      });

      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          if (isPudo == true) {
            return PudoProfile.fromJson(baseResponse.payload);
          } else {
            return UserProfile.fromJson(baseResponse.payload);
          }
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - photoupload: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> deleteProfilePic({bool? isPudo = false}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + ((isPudo != null && isPudo == true) ? '/api/v1/pudos/me/profile-pic' : '/api/v1/users/me/profile-pic');

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await delete(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(baseResponse, () {
        deleteProfilePic(isPudo: isPudo).catchError((onError) => throw onError);
      });
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          if (isPudo == true) {
            return PudoProfile.fromJson(baseResponse.payload);
          } else {
            return UserProfile.fromJson(baseResponse.payload);
          }
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - deleteProfilePic: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setDeviceInfo({required DeviceInfoModel infoRequest}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/users/me/device-tokens';
    var body = jsonEncode(infoRequest.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          setDeviceInfo(infoRequest: infoRequest).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return UserProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - setDeviceInfo: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyNotifications({int limit = 20, int offset = 0}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var queryString = "?limit=$limit&offset=$offset";

    var url = _baseURL + '/api/v1/notifications$queryString';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });

      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<PudoNotification> myNotifications = <PudoNotification>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getMyNotifications().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myNotifications.add(PudoNotification.fromJson(aRow));
          }
          return myNotifications;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getMyNotifications: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> readAllMyNotifications() async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/notifications/mark-as-read';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          readAllMyNotifications().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        return baseResponse;
      }
    } on Error catch (e) {
      print('ERROR - readAllMyNotifications: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> markNotificationAsRead({required int notificationId}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/notifications/$notificationId/mark-as-read';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          markNotificationAsRead(notificationId: notificationId).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        return baseResponse;
      }
    } on Error catch (e) {
      print('ERROR - markNotificationAsRead: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyPackages({bool history = false, int limit = 20, int offset = 0}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var queryString = "?history=$history&limit=$limit&offset=$offset";

    var url = _baseURL + '/api/v1/packages$queryString';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<PudoPackage> myPackages = <PudoPackage>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getMyPackages(
            history: history,
            limit: limit,
            offset: offset,
          ).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myPackages.add(PudoPackage.fromJson(aRow));
          }
          return myPackages;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getMyPackages: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setupDelivery({
    DeliveryPackageRequest? request,
    int? userId,
    String? notes,
    String? packagePicId,
  }) async {
    if (request != null) {
    } else if (userId != null) {
      request = DeliveryPackageRequest(userId: userId, notes: notes, packagePicId: packagePicId);
    } else {
      return ErrorDescription('Error missing parameters.');
    }

    var url = _baseURL + '/api/v1/packages';
    var body = jsonEncode(request.toJson());

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          setupDelivery(
            request: request,
            userId: userId,
            notes: notes,
            packagePicId: packagePicId,
          ).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoPackage.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - setupDelivery: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> deliveryPictureUpload({
    required File anImage,
    required String externalFileId,
  }) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/packages/picture/$externalFileId';
    var uri = Uri.parse(url);

    // create multipart request
    var request = MultipartRequest("PUT", uri);
    var multipartFileSign = new MultipartFile(
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
        deliveryPictureUpload(
          anImage: anImage,
          externalFileId: externalFileId,
        ).catchError((onError) => throw onError);
      });

      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0) {
          return baseResponse;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - deliveryPictureUpload: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getPackageDetails({required int packageId}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/packages/$packageId';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getPackageDetails(
            packageId: packageId,
          ).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoPackage.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getPackageDetails : $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> changePackageStatus({required int packageId, required PudoPackageStatus newStatus, String? notes}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL;

    if (newStatus == PudoPackageStatus.ACCEPTED) {
      url = _baseURL + '/api/v1/packages/$packageId/accepted';
    } else if (newStatus == PudoPackageStatus.COLLECTED) {
      url = _baseURL + '/api/v1/packages/$packageId/collected';
    } else if (newStatus == PudoPackageStatus.NOTIFIED) {
      url = _baseURL + '/api/v1/packages/$packageId/notified';
    } else if (newStatus == PudoPackageStatus.NOTIFY_SENT) {
      url = _baseURL + '/api/v1/packages/$packageId/notified';
    } else {
      return ErrorDescription('Error Unsupported PackageStatus specified.');
    }

    String? body;
    if (notes != null) {
      var request = ChangePackageStatusRequest(notes: notes);
      body = jsonEncode(request.toJson());
    }

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          changePackageStatus(
            packageId: packageId,
            newStatus: newStatus,
            notes: notes,
          ).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoPackage.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - changePackageStatus : $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getNotificationsCount() async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var url = _baseURL + '/api/v1/notifications/count';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getNotificationsCount().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null) {
          return baseResponse;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getNotificationsCount : $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getSuggestedZoom({required double lat, required double lon}) async {
    if (_accesstoken != null) {
      _headers['Authorization'] = 'Bearer $_accesstoken';
    }

    var queryString = "?lat=$lat&lon=$lon";

    var url = _baseURL + '/api/v1/map/suggested-zoom$queryString';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });

      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getSuggestedZoom(lat: lat, lon: lon).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is int) {
          return baseResponse.payload;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      print('ERROR - getSuggestedZoom: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }
}
