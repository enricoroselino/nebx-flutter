import 'package:dio/dio.dart';
import 'package:nebx/infrastructure/services/internet_checker_implementation.dart';

class InternetInterceptor extends Interceptor {
  late final IInternetChecker _internetChecker;

  InternetInterceptor({required IInternetChecker checker}) {
    _internetChecker = checker;
  }

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    bool connection = await _internetChecker.hasInternetAccess;
    var error = DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );

    if (!connection) return handler.reject(error);
    return super.onRequest(options, handler);
  }
}