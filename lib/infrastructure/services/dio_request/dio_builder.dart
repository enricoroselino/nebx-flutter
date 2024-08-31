import 'package:dio/dio.dart';
import 'package:nebx/infrastructure/services/dio_request/dio_implementation.dart';

abstract interface class IDioBuilder {
  DioBuilder addRequestTimeOut({
    int requestTimeOutSeconds = 5,
    int receiveTimeOutSeconds = 5,
  });

  DioBuilder addBaseUrl({required String url});

  DioBuilder addRequestContentType({required String type});

  DioBuilder addDisableAutoDecode();

  DioBuilder addInterceptor({
    required Interceptor Function(Dio) interceptor,
  });

  IDioClient build();
}

class DioBuilder implements IDioBuilder {
  late final BaseOptions _options;
  late final List<Interceptor> _interceptors;
  late final Dio _dio;

  DioBuilder() {
    _options = BaseOptions();
    _interceptors = [];
    _dio = Dio();
  }

  @override
  DioBuilder addRequestTimeOut({
    int requestTimeOutSeconds = 5,
    int receiveTimeOutSeconds = 5,
  }) {
    _options.connectTimeout = Duration(seconds: requestTimeOutSeconds);
    _options.receiveTimeout = Duration(seconds: receiveTimeOutSeconds);
    return this;
  }

  @override
  DioBuilder addBaseUrl({required String url}) {
    _options.baseUrl = url;
    return this;
  }

  @override
  DioBuilder addRequestContentType({required String type}) {
    final header = {Headers.contentTypeHeader: type};
    _options.headers.addAll(header);
    return this;
  }

  @override
  DioBuilder addDisableAutoDecode() {
    _options.responseType = ResponseType.plain;
    return this;
  }

  @override
  DioBuilder addInterceptor({
    required Interceptor Function(Dio) interceptor,
  }) {
    _interceptors.add(interceptor(_dio));
    return this;
  }

  @override
  IDioClient build() {
    _dio.options = _options;
    _dio.interceptors.addAll(_interceptors);
    return DioImplementation(dioClient: _dio);
  }
}
