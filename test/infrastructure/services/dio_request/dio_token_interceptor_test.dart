import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:nebx/nebx.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_header_key.dart';
import 'package:nebx_verdict/nebx_verdict.dart';

class LoginTestResponse {
  final String accessToken;
  final String refreshToken;

  LoginTestResponse._({required this.accessToken, required this.refreshToken});

  factory LoginTestResponse.fromJson(Map<String, dynamic> jsonObject) {
    return LoginTestResponse._(
      accessToken: jsonObject["accessToken"],
      refreshToken: jsonObject["refreshToken"],
    );
  }
}

void main() async {
  late Dio dio;
  late DioAdapter dioAdapter;
  late IDioClient sut;

  const String baseUrl = "https://roselino.nebx.my.id/dummy";
  String token = "";
  String refreshToken = "";
  const String expectedToken = "my-valid-token";
  const String refreshedToken = "my-refreshed-token";
  const String expectedRefreshToken = "my-valid-refresh-token";
  const String authorizedData = "ok";

  String tokenLoader() {
    // token loader is only to load the token not includes the saving mechanism
    // the saving mechanism is done at your login repository
    return token;
  }

  Future<IVerdict<String>> tokenRefresher(IDioClient client) async {
    // i think don't need to utilize the passed internal client
    // its the user responsibility to test this function, RIGHT ?
    return await Future<IVerdict<String>>.value(
      Verdict.successful(refreshedToken),
    );
  }

  group("JWT Interceptor", () {
    const String loginEndpoint = "/login";
    const String authorizedOnlyEndpoint = "/secret";
    const String refreshTokenEndpoint = "/refresh";

    final loginPayload = {
      "username": "roselino",
      "password": "mystrongpassword"
    };

    final refreshTokenPayload = {"refreshToken": expectedRefreshToken};

    Future<IVerdict> loginRepository(IDioClient client) async {
      final result = await client.post(url: loginEndpoint, data: loginPayload);
      final loginResponse = LoginTestResponse.fromJson(jsonDecode(result.data));
      token = loginResponse.accessToken;
      refreshToken = loginResponse.refreshToken;
      return result;
    }

    setUp(() {
      final jwtInterceptor = JWTInterceptor(
        onTokenLoad: tokenLoader,
        onTokenRefresh: (fetcher) => tokenRefresher(fetcher),
      );

      dio = DioBuilder()
          .addBaseUrl(url: baseUrl)
          .addRequestContentType(type: HttpContentType.json)
          .addInterceptor(interceptor: (client) => jwtInterceptor)
          .build();

      dioAdapter = DioAdapter(
        dio: dio,
        matcher: const FullHttpRequestMatcher(),
      );
      sut = DioImplementation(dioClient: dio);

      final loginSuccessResponse = {
        "accessToken": expectedToken,
        "refreshToken": expectedRefreshToken,
      };

      dioAdapter
        ..onPost(
          loginEndpoint,
          (server) => server.reply(200, loginSuccessResponse),
          data: loginPayload,
        )
        ..onGet(
          authorizedOnlyEndpoint,
          (server) => server.reply(200, authorizedData),
          headers: {HttpHeaderKey.authorization: "Bearer $expectedToken"},
        );
    });

    test("Auto provide authorization", () async {
      // simulate login to get authorization token
      final result = await loginRepository(sut);
      expect(result.isFailure, false);
      expect(token, expectedToken);
      expect(refreshToken, expectedRefreshToken);

      // simulate data request to authorized only endpoint
      // notice i don't provide expected token here using Options to alter
      // the http authorization header.
      final memberData = await sut.get(url: authorizedOnlyEndpoint);
      expect(memberData.isFailure, false);
      expect(jsonDecode(memberData.data), authorizedData);
    });
  });
}
