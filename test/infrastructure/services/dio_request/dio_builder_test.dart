import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nebx/nebx.dart';

void main() {
  const String validUrl = "https://roselino.nebx.my.id/dummy";
  const String brokenUrl = "roselino.nebx.my.id/dummy";
  final logInterceptor = LogInterceptor();
  const int receiveTimeout = 30;
  const int requestTimeout = 5;

  group("pattern integrity", () {
    late IDioBuilder sut;

    setUp(() {
      sut = DioBuilder();
    });

    test("builder pattern should return DioBuilder", () {
      sut
          .addBaseUrl(url: validUrl)
          .addRequestContentType(type: HttpContentType.xml)
          .addResponseContentType(type: ResponseType.stream)
          .addRequestTimeOut(
            receiveTimeOutSeconds: receiveTimeout,
            requestTimeOutSeconds: requestTimeout,
          )
          .addInterceptor(interceptor: (client) => logInterceptor);

      expect(sut.runtimeType, DioBuilder);
    });

    test("should throw argument error if not a valid url", () {
      expect(() => sut.addBaseUrl(url: brokenUrl), throwsArgumentError);
    });
  });

  group("default init", () {
    late Dio sut;

    setUp(() {
      sut = DioBuilder().build();
    });

    test("should disable auto decoding", () {
      expect(sut.options.responseType, ResponseType.plain);
    });
  });

  group("builder method result", () {
    late Dio sut;

    setUp(() {
      sut = DioBuilder()
          .addBaseUrl(url: validUrl)
          .addRequestContentType(type: HttpContentType.xml)
          .addResponseContentType(type: ResponseType.stream)
          .addRequestTimeOut(
            receiveTimeOutSeconds: receiveTimeout,
            requestTimeOutSeconds: requestTimeout,
          )
          .addInterceptor(interceptor: (client) => logInterceptor)
          .build();
    });

    test("addBaseUrl should return exact url", () {
      expect(sut.options.baseUrl, validUrl);
    });

    test("addRequestContentType should return exact type", () {
      expect(
          sut.options.headers[Headers.contentTypeHeader], HttpContentType.xml);
    });

    test("addResponseContentType should return exact type", () {
      expect(sut.options.responseType, ResponseType.stream);
    });

    test("addRequestTimeOut should return exact values", () {
      expect(sut.options.receiveTimeout?.inSeconds, receiveTimeout);
      expect(sut.options.connectTimeout?.inSeconds, requestTimeout);
    });

    test("addInterceptor should add interceptor", () {
      Type addedInterceptorType = logInterceptor.runtimeType;
      final interceptors = sut.interceptors;

      expect(interceptors.whereType<LogInterceptor>().length, 1);
      expect(interceptors.whereType<LogInterceptor>().firstOrNull.runtimeType,
          addedInterceptorType);
    });
  });
}
