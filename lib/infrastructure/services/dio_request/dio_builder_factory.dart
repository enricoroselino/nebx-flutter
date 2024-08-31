import 'package:flutter/foundation.dart';
import 'package:nebx/infrastructure/services/dio_request/constants/http_content_type.dart';
import 'package:nebx/infrastructure/services/dio_request/dio_builder.dart';
import 'package:nebx/infrastructure/services/dio_request/dio_implementation.dart';
import 'package:nebx/infrastructure/services/dio_request/interceptors/internet_interceptor.dart';
import 'package:nebx/infrastructure/services/dio_request/interceptors/jwt_interceptor.dart';
import 'package:nebx/infrastructure/services/internet_checker_implementation.dart';
import 'package:nebx/shared/models/verdict.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioBuilderFactory {
  DioBuilderFactory._();

  static IDioBuilder get _builderBase => DioBuilder();

  static IDioBuilder clientPlain({
    required String baseUrl,
    String requestContentType = HttpContentType.json,
  }) {
    return _builderBase
        .addBaseUrl(url: baseUrl)
        .addDisableAutoDecode()
        .addRequestContentType(type: requestContentType);
  }

  static IDioBuilder clientBasic({
    required String baseUrl,
    required IInternetChecker internetChecker,
    String requestContentType = HttpContentType.json,
  }) {
    final logger = PrettyDioLogger(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    );

    final internetInterceptor = InternetInterceptor(checker: internetChecker);

    var builder = clientPlain(baseUrl: baseUrl)
        .addRequestContentType(type: requestContentType)
        .addInterceptor(interceptor: (client) => internetInterceptor);

    if (kReleaseMode) {
      builder.addInterceptor(interceptor: (client) => logger);
    }

    return builder;
  }

  static IDioBuilder clientJsonWebToken({
    required String baseUrl,
    required String Function() onTokenLoad,
    Future<IVerdict<String>> Function(IDioClient)? onTokenRefresh,
    required IInternetChecker internetChecker,
    String requestContentType = HttpContentType.json,
  }) {
    final jwtInterceptor = JWTInterceptor(
      onTokenLoad: onTokenLoad,
      onTokenRefresh: onTokenRefresh,
    );

    var builder = clientBasic(
        baseUrl: baseUrl,
        internetChecker: internetChecker
    )
        .addRequestContentType(type: requestContentType)
        .addInterceptor(interceptor: (client) => jwtInterceptor);

    return builder;
  }
}
