import 'package:dio/dio.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_status_codes.dart';
import 'package:nebx/src/infrastructure/services/dio_request/dio_builder_factory.dart';
import 'package:nebx/src/infrastructure/services/dio_request/dio_implementation.dart';
import 'package:nebx/src/shared/helpers/token_helper.dart';
import 'package:nebx_verdict/nebx_verdict.dart';

class JWTInterceptor extends Interceptor {
  late final Future<String> Function() _onJWTLoad;
  late final Future<IVerdict<String>> Function(IDioClient)? _onJWTRefresh;

  JWTInterceptor({
    required Future<String> Function() onTokenLoad,
    Future<IVerdict<String>> Function(IDioClient)? onTokenRefresh,
  }) {
    _onJWTLoad = onTokenLoad;
    _onJWTRefresh = onTokenRefresh;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String accessToken = await _onJWTLoad();

    // continue the request if accessToken not available yet
    if (accessToken.trim().isEmpty) return super.onRequest(options, handler);

    TokenHelper.addJWTHeader(
      headers: options.headers,
      token: accessToken,
    );

    return super.onRequest(options, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_onJWTRefresh == null) return super.onError(err, handler);

    if (err.response?.statusCode != HttpStatusCode.unauthorized) {
      return super.onError(err, handler);
    }

    final IDioClient newClient = DioBuilderFactory.clientBasic(
      baseUrl: err.requestOptions.baseUrl,
    ).buildErrorHandling();

    final refreshResult = await _onJWTRefresh(newClient);
    if (refreshResult.isFailure || refreshResult.data == null) {
      return super.onError(err, handler);
    }

    final newToken = refreshResult.data!.trim();
    if (newToken.isEmpty) return super.onError(err, handler);

    TokenHelper.addJWTHeader(
        headers: err.requestOptions.headers, token: newToken);

    final IVerdict<Response> retryResult =
        await newClient.fetch(requestOptions: err.requestOptions);
    if (retryResult.isFailure) return super.onError(err, handler);

    newClient.close(); // closing the client so it doesn't take more resource
    return handler.resolve(retryResult.data as Response);
  }
}
