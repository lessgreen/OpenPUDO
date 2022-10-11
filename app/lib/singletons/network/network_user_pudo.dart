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

part of 'network_commons.dart';

mixin NetworkManagerUserPudo on NetworkGeneral {
  Future<dynamic> registerPudo(RegistrationPudoModel requestModel) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      var url = "$_baseURL/api/v2/auth/register/pudo";
      var body = jsonEncode(requestModel.toRequest().toJson());
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
      if (baseResponse.returnCode == 0 && baseResponse.payload != null) {
        var accessTokenData = AccessTokenData.fromJson(baseResponse.payload);
        setAccessTokenData(accessTokenData);
        setAccessToken(accessTokenData.accessToken);
      }
      return baseResponse;
    } catch (e) {
      safePrint('ERROR - registerPudo: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getMyPudoUsers() async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = "$_baseURL/api/v2/pudo/me/users";
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
      List<UserSummary> myUsers = <UserSummary>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getMyPudoUsers().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myUsers.add(UserSummary.fromJson(aRow));
          }
          return myUsers;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getMyPudoUsers: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> setMyPudoAddress(AddressMarker address) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }
      var url = "$_baseURL/api/v1/pudos/me/address";
      var body = jsonEncode(address.toJson());
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => put(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout)),
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
    } catch (e) {
      safePrint('ERROR - setMyPudoAddress: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> setMyPudoProfile(PudoProfile profile) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = "$_baseURL/api/v1/pudos/me";
      var body = jsonEncode(profile.toJson());

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => put(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout)),
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
    } catch (e) {
      safePrint('ERROR - setMyPudoProfile: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getMyPudoProfile() async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = "$_baseURL/api/v2/pudo/me";
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
    } catch (e) {
      safePrint('ERROR - getMyPudoProfile: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> updatePudo(UpdatePudoRequest requestModel) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      var url = "$_baseURL/api/v2/pudo/me";
      var body = jsonEncode(requestModel.toJson());
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
          updatePudo(requestModel).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - updatePudo: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> updatePudoPolicy(List<RewardOption> rewardOptions) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      var url = "$_baseURL/api/v2/pudo/me/reward-policy";
      var body = jsonEncode(rewardOptions.map((e) => e.toJson()).toList());
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
          updatePudoPolicy(rewardOptions).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return PudoProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - updatePudoRewardPolicy: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getPlacemarkDetails(MapSearchAddressesRequest request) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var queryString = "?signature=${request.text}";
      if (request.lat != null && request.lon != null) {
        queryString += "&lat=${request.lat}&lon=${request.lon}";
      }

      var url = "$_baseURL/api/v2/map/address/detail/$queryString";

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
          getMyPudoProfile().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return GeoMarker.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getPlacemarkDetails: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }
}
