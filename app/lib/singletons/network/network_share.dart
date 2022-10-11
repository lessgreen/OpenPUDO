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

mixin NetworkShare on NetworkGeneral {
  Future<dynamic> getDynamicLink({required String dynamicLinkId}) async {
    try {
      if (!isOnline) {
        throw ("Network is offline");
      }
      if (_accessToken != null) {
        _headers['Authorization'] = 'Bearer $_accessToken';
      }
      var url = '$_baseURL/api/v2/share/link/$dynamicLinkId';
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
          getDynamicLink(dynamicLinkId: dynamicLinkId).catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 && baseResponse.payload != null && baseResponse.payload is Map) {
          return DynamicLinkResponse.fromJson(baseResponse.payload);
        } else {
          throw ErrorDescription('Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } catch (e) {
      safePrint('ERROR - getDynamicLink: $e');
      _refreshTokenRetryCounter = 0;
      rethrow;
    }
  }
}
