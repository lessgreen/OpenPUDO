part of 'network_shared.dart';

mixin NetworkManagerUserPudo on NetworkGeneral {
  Future<dynamic> registerPudo({
    required String password,
    required String firstName,
    required String lastName,
    required String businessName,
    String? email,
    String? phoneNumber,
    String? username,
    String? vat,
    String? contactNotes,
    String? businessPhone,
  }) async {
    PudoProfile pudoProfile = PudoProfile(
      businessName: businessName,
      contactNotes: contactNotes,
      vat: vat,
      phoneNumber: businessPhone,
    );
    UserProfile userProfile = UserProfile(
      firstName: firstName,
      lastName: lastName,
    );
    RegistrationRequest aRequest = RegistrationRequest(
      password: password,
      user: userProfile,
      pudo: pudoProfile,
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
      _print('ERROR - registerPudo: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyPudoUsers() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/pudos/me/users';

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
      List<UserProfile> myUsers = <UserProfile>[];

      var needHandleTokenRefresh = _handleTokenRefresh(
        baseResponse,
            () {
          getMyPudoUsers().catchError((onError) => throw onError);
        },
      );
      if (needHandleTokenRefresh == false) {
        if (baseResponse.returnCode == 0 &&
            baseResponse.payload != null &&
            baseResponse.payload is List) {
          for (dynamic aRow in baseResponse.payload) {
            myUsers.add(UserProfile.fromJson(aRow));
          }
          return myUsers;
        } else {
          throw ErrorDescription(
              'Error ${baseResponse.returnCode}: ${baseResponse.message}');
        }
      }
    } on Error catch (e) {
      _print('ERROR - getMyPudoUsers: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setMyPudoAddress(AddressMarker address) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/pudos/me/address';
    var body = jsonEncode(address.toJson());

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
          setMyPudoAddress(address).catchError((onError) => throw onError);
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
      _print('ERROR - setMyPudoAddress: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> setMyPudoProfile(PudoProfile profile) async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/pudos/me';
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
          setMyPudoProfile(profile).catchError((onError) => throw onError);
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
      _print('ERROR - setMyPudoProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }

  Future<dynamic> getMyPudoProfile() async {
    if (_accessToken != null) {
      _headers['Authorization'] = 'Bearer $_accessToken';
    }

    var url = _baseURL + '/api/v1/pudos/me';

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
          getMyPudoProfile().catchError((onError) => throw onError);
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
      _print('ERROR - getMyPudoProfile: $e');
      _refreshTokenRetryCounter = 0;
      return e;
    }
  }
}
