part of 'network_shared.dart';

mixin NetworkManagerUser on NetworkGeneral {
  //TODO: implement API calls (user related)

  Future<dynamic> login(
      {required String login, required String password}) async {
    LoginRequest aRequest = LoginRequest(
      phoneNumber: login,
      otp: password,
    );
    var url = _baseURL + '/api/v2/auth/login/confirm';
    var body = jsonEncode(aRequest.toJson());
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
      }
      return baseResponse;
    } on Error catch (e) {
      safePrint('ERROR - login: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> sendPhoneAuth({required String phoneNumber}) async {
    /*UserProfile userProfile = UserProfile(
      firstName: firstName,
      lastName: lastName,
      ssn: ssn,
    );*/
    RegistrationRequest aRequest = RegistrationRequest(
      phoneNumber: phoneNumber,
    );
    var url = _baseURL + '/api/v2/auth/login/send';
    var body = jsonEncode(aRequest.toJson());
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
      return baseResponse;
    } on Error catch (e) {
      safePrint('ERROR - registerUser: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> registerUser(
      {required String name, required String surname}) async {
    var url = _baseURL + '/api/v2/auth/register/customer';
    var body = jsonEncode({
      "user": {"firstName": name, "lastName": surname}
    });
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
      }
      return baseResponse;
    } on Error catch (e) {
      safePrint('ERROR - registerUser: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyProfile() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v2/user/me';
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

  Future<dynamic> setMyProfile(UserProfile profile) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v2/user/me';
    var body = jsonEncode(
        {"firstName": profile.firstName, "lastName": profile.lastName});

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response =
          await put(Uri.parse(url), body: body, headers: _headers)
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
    } on Error catch (e) {
      safePrint('ERROR - setMyProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> deleteProfilePic({bool? isPudo = false}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL +
        ((isPudo != null && isPudo == true)
            ? '/api/v1/pudos/me/profile-pic'
            : '/api/v1/users/me/profile-pic');

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
    } on Error catch (e) {
      safePrint('ERROR - deleteProfilePic: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<Uint8List> profilePic(String id) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v2/file/$id';
    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response = await get(Uri.parse(url), headers: _headers)
          .timeout(Duration(seconds: _timeout));
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = false;
      });
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      throw ErrorDescription('Error ${response.statusCode}: ${response.body}');
    } on Error catch (e) {
      safePrint('ERROR - deleteProfilePic: $e');
      _refreshTokenRetryCounter = 0;
      var data = await rootBundle.load('assets/placeholderImage.jpg');
      return data.buffer.asUint8List();
    }
  }

  Future<dynamic> getPublicProfile(String userId) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/users/$userId';

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
    } on Error catch (e) {
      safePrint('ERROR - getPublicProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> addPudoFavorite(String pudoId) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v2/user/me/pudos/$pudoId';

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
      safePrint('ERROR - addPudoFavorite: $e');
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
      safePrint('ERROR - removePudoFavorite: $e');
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
      safePrint('ERROR - getMyPudos: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> updateUserPreferences({required bool showNumber}) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v2/user/me/preferences';
    var body = jsonEncode({"showPhoneNumber": showNumber});

    try {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _networkActivity.value = true;
      });
      Response response =
          await put(Uri.parse(url), body: body, headers: _headers)
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
    } on Error catch (e) {
      safePrint('ERROR - updateUserPreferences: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }
}
