import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_content_type.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_header_key.dart';
import 'package:nebx/src/infrastructure/services/dio_request/dio_issue_handler.dart';
import 'package:nebx_verdict/nebx_verdict.dart';

abstract interface class IDioClient {
  Future<IVerdict<T>> get<T>({
    required String url,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<IVerdict<List<Uint8>>> getBytes({
    required String url,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<IVerdict<dynamic>> post({
    required String url,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<IVerdict<dynamic>> postStream({
    required String url,
    required List<Uint8> data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
  });

  Future<IVerdict<dynamic>> delete({
    required String url,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<IVerdict<dynamic>> put({
    required String url,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<IVerdict<Response>> fetch({
    required RequestOptions requestOptions,
  });

  Future<IVerdict> download({
    required String url,
    required String savePath,
    Object? data,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  });

  Future<IVerdict> upload({
    required String url,
    required FormData data,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  });

  void close({bool force = false});

  Dio get dio;
}

// letting the return type dynamic as the body message parsing into object is not
// ... a http client responsibility.
class DioImplementation implements IDioClient {
  late final Dio _client;
  late final IDioIssueHandler _issueHandler;

  DioImplementation({required Dio dioClient}) {
    _client = dioClient;
    _issueHandler = DioIssueHandler();
  }

  @override
  Future<IVerdict<T>> get<T>({
    required String url,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _client.get(
        url,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return Verdict.successful(response.data);
    } on DioException catch (e) {
      final issue = _issueHandler.mapIssue(error: e);
      return Verdict.failed(issue);
    } catch (e) {
      final issue = Issue.other(e.toString());
      return Verdict.failed(issue);
    }
  }

  @override
  Future<IVerdict<List<Uint8>>> getBytes({
    required String url,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final defaultOptions = Options(responseType: ResponseType.bytes);
    // override the passed option response type, if any
    options?.responseType = ResponseType.bytes;

    return await get<List<Uint8>>(
      url: url,
      queryParams: queryParams,
      options: options ?? defaultOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<IVerdict<dynamic>> post({
    required String url,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await _client.post(
        url,
        data: data,
        options: options,
        queryParameters: queryParams,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      );

      return Verdict.successful(response.data);
    } on DioException catch (e) {
      final issue = _issueHandler.mapIssue(error: e);
      return Verdict.failed(issue);
    } catch (e) {
      final issue = Issue.other(e.toString());
      return Verdict.failed(issue);
    }
  }

  @override
  Future<IVerdict<dynamic>> postStream({
    required String url,
    required List<Uint8> data,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    Options? options,
    void Function(int, int)? onReceiveProgress,
    void Function(int, int)? onSendProgress,
  }) async {
    final streamHeader = {HttpHeaderKey.contentLength: data.length};
    final defaultOptions = Options(headers: streamHeader);
    // override the header of passed options, if any
    options?.headers?.addAll(streamHeader);

    return await post(
      url: url,
      data: Stream.fromIterable(data.map((e) => [e])),
      options: options ?? defaultOptions,
      queryParams: queryParams,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
  }

  @override
  Future<IVerdict<dynamic>> delete({
    required String url,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _client.delete(
        url,
        data: data,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );

      return Verdict.successful(response.data);
    } on DioException catch (e) {
      final issue = _issueHandler.mapIssue(error: e);
      return Verdict.failed(issue);
    } catch (e) {
      final issue = Issue.other(e.toString());
      return Verdict.failed(issue);
    }
  }

  @override
  Future<IVerdict<dynamic>> put({
    required String url,
    Object? data,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _client.put(
        url,
        data: data,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );

      return Verdict.successful(response.data);
    } on DioException catch (e) {
      final issue = _issueHandler.mapIssue(error: e);
      return Verdict.failed(issue);
    } catch (e) {
      final issue = Issue.other(e.toString());
      return Verdict.failed(issue);
    }
  }

  @override
  Future<IVerdict<Response<dynamic>>> fetch({
    required RequestOptions requestOptions,
  }) async {
    try {
      final response = await _client.fetch(requestOptions);
      return Verdict.successful(response);
    } on DioException catch (e) {
      final issue = _issueHandler.mapIssue(error: e);
      return Verdict.failed(issue);
    } catch (e) {
      final issue = Issue.other(e.toString());
      return Verdict.failed(issue);
    }
  }

  @override
  Future<IVerdict> upload({
    required String url,
    required FormData data,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final options = Options(contentType: HttpContentType.multipart);

      await _client.post(
        url,
        data: data,
        options: options,
        queryParameters: queryParams,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      final issue = _issueHandler.mapIssue(error: e);
      return Verdict.failed(issue);
    } catch (e) {
      final issue = Issue.other(e.toString());
      return Verdict.failed(issue);
    }

    return Verdict.successful();
  }

  @override
  Future<IVerdict> download({
    required String url,
    required String savePath,
    Object? data,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final headers = {HttpHeaderKey.acceptEncoding: '*'};
      final options = Options(
        responseType: ResponseType.bytes,
        headers: headers,
      );

      await _client.download(
        url,
        savePath,
        options: options,
        data: data,
        queryParameters: queryParams,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      final issue = _issueHandler.mapIssue(error: e);
      return Verdict.failed(issue);
    } catch (e) {
      final issue = Issue.other(e.toString());
      return Verdict.failed(issue);
    }

    return Verdict.successful();
  }

  @override
  void close({bool force = false}) {
    _client.close(force: force);
  }

  @override
  Dio get dio => _client;
}

extension DioExtension on Dio {
  IDioClient get withErrorHandler {
    return DioImplementation(dioClient: this);
  }
}
