part of 'network.dart';

mixin NetworkManagerNotification on NetworkManager {
  Future<dynamic> getNotificationsCount() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/notifications/count';

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
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - getNotificationsCount : $e');
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
      Response response = await post(Uri.parse(url), headers: _headers)
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
          markNotificationAsRead(notificationId: notificationId)
              .catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        return baseResponse;
      }
    } on Error catch (e) {
      _print('ERROR - markNotificationAsRead: $e');
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
      Response response = await post(Uri.parse(url), headers: _headers)
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
          readAllMyNotifications().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        return baseResponse;
      }
    } on Error catch (e) {
      _print('ERROR - readAllMyNotifications: $e');
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
      Response response = await get(Uri.parse(url), headers: _headers)
          .timeout(Duration(seconds: _timeout));
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
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myNotifications.add(PudoNotification.fromJson(aRow));
          }
          return myNotifications;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - getMyNotifications: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }
}
