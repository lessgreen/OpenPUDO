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

mixin NetworkManagerPackages on NetworkGeneral {
  Future<dynamic> getPackageDetailsByQrCode({required String shareLink}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = _baseURL + '/api/v2/package/by-qrcode/$shareLink';
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout)),
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
          getPackageDetailsByQrCode(
            shareLink: shareLink,
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
    } catch (e) {
      safePrint('ERROR - getPackageDetailsByQrCode : $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getPackageDetails({required int packageId}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = _baseURL + '/api/v2/package/$packageId';
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout)),
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
    } catch (e) {
      safePrint('ERROR - getPackageDetails : $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> changePackageStatus({required int packageId, required PudoPackageStatus newStatus, String? notes}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var url = _baseURL;

      if (newStatus == PudoPackageStatus.accepted) {
        url = _baseURL + '/api/v2/package/$packageId/accepted';
      } else if (newStatus == PudoPackageStatus.collected) {
        url = _baseURL + '/api/v2/package/$packageId/collected';
      } else if (newStatus == PudoPackageStatus.notified) {
        url = _baseURL + '/api/v2/package/$packageId/notified';
      } else if (newStatus == PudoPackageStatus.notifySent) {
        url = _baseURL + '/api/v2/package/$packageId/notified';
      } else {
        return ErrorDescription('Error Unsupported PackageStatus specified.');
      }
      String? body;
      var request = ChangePackageStatusRequest(notes: notes);
      body = jsonEncode(request.toJson());
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout)),
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
    } catch (e) {
      safePrint('ERROR - changePackageStatus : $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> deliveryPictureUpload({
    required File anImage,
    required String externalFileId,
  }) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
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
    } catch (e) {
      safePrint('ERROR - deliveryPictureUpload: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> setupDelivery({
    DeliveryPackageRequest? request,
    int? userId,
    String? notes,
  }) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (request != null) {
      } else if (userId != null) {
        request = DeliveryPackageRequest(userId: userId, notes: notes);
      } else {
        return ErrorDescription('Error missing parameters.');
      }
      print(notes);
      var url = _baseURL + '/api/v2/package';
      var body = jsonEncode(request.toJson());

      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => post(Uri.parse(url), body: body, headers: _headers).timeout(Duration(seconds: _timeout)),
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
          setupDelivery(
            request: request,
            userId: userId,
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
    } catch (e) {
      safePrint('ERROR - setupDelivery: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> getMyPackages({bool isPudo = false, bool history = false, int limit = 20, int offset = 0, bool enablePagination = true}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }

      var queryString = enablePagination ? "?history=$history&limit=$limit&offset=$offset" : "?history=$history";

      var url = _baseURL + '/api/v2/${isPudo ? "pudo" : "user"}/me/packages$queryString';

      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await r.retry(
        () => get(Uri.parse(url), headers: _headers).timeout(Duration(seconds: _timeout)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      final codeUnits = response.body.codeUnits;
      var decodedUTF8 = const Utf8Decoder().convert(codeUnits);
      var json = jsonDecode(decodedUTF8);
      var baseResponse = OPBaseResponse.fromJson(json);
      List<PackageSummary> myPackages = <PackageSummary>[];

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
            myPackages.add(PackageSummary.fromJson(aRow));
          }
          return myPackages;
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getMyPackages: $e');
      _refreshTokenRetryCounter = 0;
      _networkActivity.value = false;
      return e;
    }
  }

  Future<dynamic> packagePhotoUpload(File anImage, int packageId) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v2/package/$packageId/picture';
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
        packagePhotoUpload(anImage, packageId).catchError((onError) => throw onError);
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
}
