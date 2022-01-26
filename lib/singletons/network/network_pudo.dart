part of 'network_shared.dart';

mixin NetworkManagerPudo on NetworkGeneral {
  //TODO: implement API calls (pudo related)
  Future<dynamic> getSuggestedZoom(
      {required double lat, required double lon}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var queryString = "?lat=$lat&lon=$lon";

    var url = _baseURL + '/api/v1/map/suggested-zoom$queryString';

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
          getSuggestedZoom(lat: lat, lon: lon)
              .catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is int) {
          return baseResponse.payload;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      safePrint('ERROR - getSuggestedZoom: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getPudoDetails({required String pudoId}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v2/pudo/$pudoId';

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
          getPudoDetails(pudoId: pudoId).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is Map) {
          return PudoProfile.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      safePrint('ERROR - getPudoDetails: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getPudos(
      {double? lat, double? lon, int? zoom, String? text}) async {
    var queryString = "";
    if (lat != null && lon != null && zoom != null) {
      queryString = "?lat=$lat&lon=$lon&zoom=$zoom";
    } else if (text != null) {
      queryString = "?text=$text";
    }
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v2/map/pudos$queryString';

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
      List<PudoMarker> pudos = <PudoMarker>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
        () {
          getPudos(lat: lat, lon: lon, zoom: zoom)
              .catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            pudos.add(PudoMarker.fromJson(aRow));
          }
          return pudos;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      safePrint('ERROR - getPudos: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

}
