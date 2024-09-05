import 'package:flutter/foundation.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_content_type.dart';
import 'package:nebx/src/infrastructure/services/dio_request/dio_builder.dart';
import 'package:nebx/src/infrastructure/services/dio_request/dio_implementation.dart';
import 'package:nebx/src/infrastructure/services/dio_request/interceptors/internet_interceptor.dart';
import 'package:nebx/src/infrastructure/services/dio_request/interceptors/jwt_interceptor.dart';
import 'package:nebx/src/infrastructure/services/internet_checker_implementation.dart';
import 'package:nebx_verdict/nebx_verdict.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioBuilderFactory {
  DioBuilderFactory._();

  static IDioBuilder get _builderBase => DioBuilder();

  static PrettyDioLogger get _logger {
    final logger = PrettyDioLogger(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    );

    return logger;
  }

  static IDioBuilder clientPlain({
    String? baseUrl,
    String requestContentType = HttpContentType.json,
  }) {
    return _builderBase
        .addBaseUrl(url: baseUrl ?? "")
        .addRequestContentType(type: requestContentType);
  }

  static IDioBuilder clientBasic({
    String? baseUrl,
    IInternetChecker? internetChecker,
    String requestContentType = HttpContentType.json,
  }) {
    final netChecker = internetChecker ?? InternetCheckerImplementation();
    final internetInterceptor = InternetInterceptor(checker: netChecker);

    final builder = _builderBase
        .addBaseUrl(url: baseUrl ?? "")
        .addRequestContentType(type: requestContentType)
        .addInterceptor(interceptor: (client) => internetInterceptor);

    if (!kReleaseMode) {
      builder.addInterceptor(interceptor: (client) => _logger);
    }

    return builder;
  }

  static IDioBuilder clientJsonWebToken({
    String? baseUrl,
    required String Function() onTokenLoad,
    Future<IVerdict<String>> Function(IDioClient)? onTokenRefresh,
    IInternetChecker? internetChecker,
    String requestContentType = HttpContentType.json,
  }) {
    final jwtInterceptor = JWTInterceptor(
      onTokenLoad: onTokenLoad,
      onTokenRefresh: onTokenRefresh,
    );

    final netChecker = internetChecker ?? InternetCheckerImplementation();
    final internetInterceptor = InternetInterceptor(checker: netChecker);

    final builder = _builderBase
        .addBaseUrl(url: baseUrl ?? "")
        .addRequestContentType(type: requestContentType)
        .addInterceptor(interceptor: (client) => internetInterceptor)
        .addInterceptor(interceptor: (client) => jwtInterceptor);

    if (!kReleaseMode) {
      builder.addInterceptor(interceptor: (client) => _logger);
    }

    return builder;
  }
}
