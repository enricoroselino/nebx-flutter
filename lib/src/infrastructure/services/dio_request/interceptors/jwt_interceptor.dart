import 'package:dio/dio.dart';
import 'package:nebx/src/infrastructure/services/dio_request/dio_builder_factory.dart';
import 'package:nebx/src/infrastructure/services/dio_request/dio_implementation.dart';
import 'package:nebx/src/shared/helpers/token_helper.dart';
import 'package:nebx_verdict/nebx_verdict.dart';
import 'package:universal_io/io.dart';

class JWTInterceptor extends Interceptor {
  late final String Function() _onJWTLoad;
  late final Future<IVerdict<String>> Function(IDioClient)? _onJWTRefresh;

  JWTInterceptor({
    required String Function() onTokenLoad,
    Future<IVerdict<String>> Function(IDioClient)? onTokenRefresh,
  }) {
    _onJWTLoad = onTokenLoad;
    _onJWTRefresh = onTokenRefresh;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String accessToken = _onJWTLoad();
    // continue the request if accessToken not available
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

    if (err.response?.statusCode != HttpStatus.unauthorized) {
      return super.onError(err, handler);
    }

    final newClient = DioBuilderFactory.clientPlain(
      baseUrl: err.requestOptions.baseUrl,
    ).build();

    final refreshResult = await _onJWTRefresh(newClient);
    if (refreshResult.isFailure) return super.onError(err, handler);

    final newToken = refreshResult.data!;
    TokenHelper.addJWTHeader(
      headers: err.requestOptions.headers,
      token: newToken,
    );

    final retryResult =
        await newClient.fetch(requestOptions: err.requestOptions);
    if (retryResult.isFailure) return super.onError(err, handler);

    newClient.close();
    return handler.resolve(retryResult.data);
  }
}
