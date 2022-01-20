part of 'network_shared.dart';
mixin NetworkManagerPackages on NetworkGeneral{
  //TODO: implement API calls (package related)
  Future<dynamic> getPackageDetails({required int packageId}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/packages/$packageId';

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
          getPackageDetails(
            packageId: packageId,
          ).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is Map) {
          return PudoPackage.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - getPackageDetails : $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> changePackageStatus(
      {required int packageId,
        required PudoPackageStatus newStatus,
        String? notes}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
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
          changePackageStatus(
            packageId: packageId,
            newStatus: newStatus,
            notes: notes,
          ).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is Map) {
          return PudoPackage.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - changePackageStatus : $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> deliveryPictureUpload({
    required File anImage,
    required String externalFileId,
  }) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/packages/picture/$externalFileId';
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
        deliveryPictureUpload(
          anImage: anImage,
          externalFileId: externalFileId,
        ).catchError((onError) => throw onError);
      });

      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0) {
          return baseResponse;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - deliveryPictureUpload: $e');
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
      request = DeliveryPackageRequest(
          userId: userId, notes: notes, packagePicId: packagePicId);
    } else {
      return ErrorDescription('Error missing parameters.');
    }

    var url = _baseURL + '/api/v1/packages';
    var body = jsonEncode(request.toJson());

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
          setupDelivery(
            request: request,
            userId: userId,
            notes: notes,
            packagePicId: packagePicId,
          ).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is Map) {
          return PudoPackage.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - setupDelivery: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyPackages(
      {bool history = false, int limit = 20, int offset = 0}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var queryString = "?history=$history&limit=$limit&offset=$offset";

    var url = _baseURL + '/api/v1/packages$queryString';

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
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myPackages.add(PudoPackage.fromJson(aRow));
          }
          return myPackages;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - getMyPackages: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> addPudoFavorite(String pudoId) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/users/me/pudos/$pudoId';

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await put(Uri.parse(url), headers: _headers)
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
    } on Error catch (e) {
      _print('ERROR - addPudoFavorite: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> removePudoFavorite(String pudoId) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/users/me/pudos/$pudoId';

    try {
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
    } on Error catch (e) {
      _print('ERROR - removePudoFavorite: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyPudos() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/users/me/pudos';

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
    } on Error catch (e) {
      _print('ERROR - getMyPudos: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }


}