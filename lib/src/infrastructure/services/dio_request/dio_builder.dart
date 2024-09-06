import 'package:dio/dio.dart';

abstract interface class IDioBuilder {
  DioBuilder addRequestTimeOut({
    int requestTimeOutSeconds = 5,
    int receiveTimeOutSeconds = 5,
  });

  DioBuilder addBaseUrl({required String url});

  DioBuilder addRequestContentType({required String type});

  DioBuilder addResponseContentType({ResponseType type = ResponseType.plain});

  DioBuilder addInterceptor({
    required Interceptor Function(Dio) interceptor,
  });

  Dio build();
}

class DioBuilder implements IDioBuilder {
  late final BaseOptions _options;
  late final List<Interceptor> _interceptors;
  late final Dio _dio;

  DioBuilder({bool autoDecode = false}) {
    _options = BaseOptions();
    _interceptors = [];
    _dio = Dio();

    // toggle dio auto decoding.
    if (!autoDecode) addResponseContentType(type: ResponseType.plain);
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
  DioBuilder addResponseContentType({ResponseType type = ResponseType.plain}) {
    _options.responseType = type;
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
  Dio build() {
    _dio.options = _options;
    _dio.interceptors.addAll(_interceptors);
    return _dio;
  }
}
