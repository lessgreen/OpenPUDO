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
      _print('ERROR - login: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> registerUser(
      {required String password,
      required String firstName,
      required String lastName,
      String? email,
      String? phoneNumber,
      String? username,
      String? ssn}) async {
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
      _print('ERROR - registerUser: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyProfile() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/users/me';

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
    } on Error catch (e) {
      _print('ERROR - getMyProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setMyProfile(UserProfile profile) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/users/me';
    var body = jsonEncode(profile.toJson());

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
      _print('ERROR - setMyProfile: $e');
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
      _print('ERROR - deleteProfilePic: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<Uint8List> profilePic(String id) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }
    var url = _baseURL + '/api/v1/file/$id';

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
      _print('ERROR - deleteProfilePic: $e');
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
      _print('ERROR - getPublicProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }
}
