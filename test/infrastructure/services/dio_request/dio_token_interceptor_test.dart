import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:nebx/nebx.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_header_key.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_status_codes.dart';

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
  // late Dio internalDio;
  late DioAdapter dioAdapter;
  // late DioAdapter dioAdapterInternal;
  late IDioClient sut;

  const String baseUrl = "https://roselino.nebx.my.id/dummy";
  String accessToken = "";
  String refreshToken = "";

  const String expectedAccessToken = "my-valid-token";
  // const String expectedRefreshedAccessToken = "my-refreshed-token";

  const String expectedRefreshToken = "my-valid-refresh-token";
  const String authorizedData = "ok";

  String tokenLoader() {
    // token loader is only to load the token not includes the saving mechanism
    // the saving mechanism is done at your login repository
    return accessToken;
  }

  // Future<IVerdict<String>> tokenRefresher(IDioClient client) async {
  //   // i think don't need to utilize the passed internal client
  //   // its the user responsibility to test this function, RIGHT ?
  //   return await Future<IVerdict<String>>.value(
  //     Verdict.successful(expectedRefreshedAccessToken),
  //   );
  // }

  group("JWT Interceptor", () {
    const String loginEndpoint = "/login";
    const String authorizedOnlyEndpoint = "/secret";
    const String refreshTokenEndpoint = "/refresh";
    const String unauthorizedEndpoint = "/unauthorized";

    final loginPayload = {
      "username": "roselino",
      "password": "mystrongpassword"
    };

    final refreshTokenPayload = {
      "refreshToken": refreshToken,
    };

    Future<IVerdict> loginRepository(IDioClient client) async {
      final result = await client.post(url: loginEndpoint, data: loginPayload);
      final loginResponse = LoginTestResponse.fromJson(jsonDecode(result.data));
      accessToken = loginResponse.accessToken;
      refreshToken = loginResponse.refreshToken;
      return result;
    }

    Future<IVerdict<String>> refreshTokenRepository(IDioClient client) async {
      final result = await client.post(
        url: refreshTokenEndpoint,
        data: refreshTokenPayload,
      );

      if (result.isFailure) return Verdict.failed(result.issue);

      final data = jsonDecode(result.data);
      accessToken = data;
      return Verdict.successful(data);
    }

    setUp(() {
      final jwtInterceptor = JWTInterceptor(
        onTokenLoad: tokenLoader,
        onTokenRefresh: (fetcher) async {
          // internalDio = fetcher.dio;
          return await refreshTokenRepository(fetcher);
        },
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
        "accessToken": expectedAccessToken,
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
          headers: {HttpHeaderKey.authorization: "Bearer $expectedAccessToken"},
        )
        ..onGet(unauthorizedEndpoint, (server) {
          final dioOptions = dio.options;
          final requestOptions = RequestOptions(
            path: unauthorizedEndpoint,
            baseUrl: dioOptions.baseUrl,
            headers: dioOptions.headers,
            responseType: dioOptions.responseType,
            contentType: dioOptions.contentType,
            method: dioOptions.method,
            sendTimeout: dioOptions.sendTimeout,
            receiveTimeout: dioOptions.receiveTimeout,
          );

          final dioException = DioException(
            response: Response(
              requestOptions: requestOptions,
              statusCode: HttpStatusCode.unauthorized,
            ),
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
          );

          return server.throws(401, dioException);
        });

      // this doesn't "hook" with the temporary created client internally
      // inside the JWTInterceptor
      // its make sense, since the client is dynamically created and disposed immediately
      // dioAdapterInternal = DioAdapter(dio: internalDio);
      // dioAdapterInternal.onPost(
      //   refreshTokenEndpoint,
      //   (server) => server.reply(
      //     200,
      //     expectedRefreshedAccessToken,
      //   ),
      // );
    });

    test("Auto provide authorization", () async {
      // simulate login to get authorization token
      final result = await loginRepository(sut);
      expect(result.isFailure, false);
      expect(accessToken, expectedAccessToken);
      expect(refreshToken, expectedRefreshToken);

      // simulate data request to authorized only endpoint
      // notice i don't provide expected token here using Options to alter
      // the http authorization header.
      final memberData = await sut.get(url: authorizedOnlyEndpoint);
      expect(memberData.isFailure, false);
      expect(jsonDecode(memberData.data), authorizedData);
    });

    test("Auto refresh token", () async {
      final result = await sut.get(url: unauthorizedEndpoint);

      // for the time being, i cant test the internally created client
      expect(result.isFailure, true);
      expect(result.issue.statusCode, 401);
      expect(result.issue.issueType, IssueType.authorization);
    });
  });
}
