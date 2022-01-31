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

mixin NetworkManagerNotification on NetworkGeneral {
  Future<dynamic> getNotificationsCount() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
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
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
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
      safePrint('ERROR - getNotificationsCount : $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> markNotificationAsRead({required int notificationId}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
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
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
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
      safePrint('ERROR - markNotificationAsRead: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> readAllMyNotifications() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
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
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
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
      safePrint('ERROR - readAllMyNotifications: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyNotifications({int limit = 20, int offset = 0}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
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
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
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
      safePrint('ERROR - getMyNotifications: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }
}
