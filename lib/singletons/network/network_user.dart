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

part of 'network_shared.dart';

mixin NetworkManagerUser on NetworkGeneral {
  //TODO: implement API calls (user related)

  Future<dynamic> login(
      {required String login, required String password}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      LoginRequest aRequest = LoginRequest(
        phoneNumber: login,
        otp: password,
      );
      var url = _baseURL + '/api/v2/auth/login/confirm';
      var body = jsonEncode(aRequest.toJson());
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => post(Uri.parse(url), body: body, headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
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
      }
      return baseResponse;
    } catch (e) {
      safePrint('ERROR - login: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> sendPhoneAuth({required String phoneNumber}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      RegistrationRequest aRequest = RegistrationRequest(
        phoneNumber: phoneNumber,
      );
      var url = _baseURL + '/api/v2/auth/login/send';
      var body = jsonEncode(aRequest.toJson());
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => post(Uri.parse(url), body: body, headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );

      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });

      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      return baseResponse;
    } catch (e) {
      safePrint('ERROR - registerUser: $e');
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> registerUser(
      {required String name, required String surname}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      var url = _baseURL + '/api/v2/auth/register/customer';
      var body = jsonEncode({
        "user": {"firstName": name, "lastName": surname}
      });
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => post(Uri.parse(url), body: body, headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
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
      }
      return baseResponse;
    } catch (e) {
      safePrint('ERROR - registerUser: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getMyProfile() async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }
      var url = _baseURL + '/api/v2/user/me';
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
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
          getMyProfile().catchError((onError) => throw onError);
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
    } catch (e) {
      safePrint('ERROR - getMyProfile: $e');
      _refreshTokenRetryCounter = 0;
      rethrow;
    }
  }

  Future<dynamic> getUserPreferences() async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }
      var url = _baseURL + '/api/v2/user/me/preferences';
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
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
          getUserPreferences().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is Map) {
          return UserPreferences.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getUserPreferences: $e');
      _refreshTokenRetryCounter = 0;
      rethrow;
    }
  }

  Future<dynamic> setMyProfile(UserProfile profile) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }
      var url = _baseURL + '/api/v2/user/me';
      var body = jsonEncode(
          {"firstName": profile.firstName, "lastName": profile.lastName});
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => put(Uri.parse(url), body: body, headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
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
          setMyProfile(profile).catchError((onError) => throw onError);
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
    } catch (e) {
      safePrint('ERROR - setMyProfile: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> deleteProfilePic({bool? isPudo = false}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = _baseURL +
          ((isPudo != null && isPudo == true)
              ? '/api/v1/pudos/me/profile-pic'
              : '/api/v1/users/me/profile-pic');
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await delete(Uri.parse(url), headers: _headers)
          .timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);

      var needHandleTokenRefresh = _handleTokenRefresh(baseResponse, () {
        deleteProfilePic(isPudo: isPudo).catchError((onError) => throw onError);
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
    } catch (e) {
      safePrint('ERROR - deleteProfilePic: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<Uint8List> profilePic(String id) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }
      var url = _baseURL + '/api/v2/file/$id';
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw ErrorDescription('Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      safePrint('ERROR - deleteProfilePic: $e');
      _refreshTokenRetryCounter = 0;
      var data = await rootBundle.load('assets/placeholderImage.jpg');
      return data.buffer.asUint8List();
    }
  }

  Future<dynamic> getPublicProfile(String userId) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = _baseURL + '/api/v1/users/$userId';
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
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
          getPublicProfile(userId).catchError((onError) => throw onError);
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
    } catch (e) {
      safePrint('ERROR - getPublicProfile: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> addPudoFavorite(String pudoId) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = _baseURL + '/api/v2/user/me/pudos/$pudoId';
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => post(Uri.parse(url), headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
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
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myPudos.add(PudoProfile.fromJson(aRow));
          }
          return myPudos;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - addPudoFavorite: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> removePudoFavorite(String pudoId) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = _baseURL + '/api/v1/users/me/pudos/$pudoId';
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await delete(Uri.parse(url), headers: _headers)
          .timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
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
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myPudos.add(PudoProfile.fromJson(aRow));
          }
          return myPudos;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - removePudoFavorite: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getMyPudos() async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = _baseURL + '/api/v2/user/me/pudos';
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
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
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myPudos.add(PudoProfile.fromJson(aRow));
          }
          return myPudos;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getMyPudos: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> updateUserPreferences({required bool showNumber}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }
      var url = _baseURL + '/api/v2/user/me/preferences';
      var body = jsonEncode({"showPhoneNumber": showNumber});
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => put(Uri.parse(url), body: body, headers: _headers)
            .timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
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
          updateUserPreferences(showNumber: showNumber)
              .catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is Map) {
          return UserPreferences.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - updateUserPreferences: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }
}
