import 'package:dio/dio.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_content_type.dart';
import 'package:nebx/src/infrastructure/services/dio_request/dio_issue_handler.dart';
import 'package:nebx/src/shared/models/issue.dart';
import 'package:nebx/src/shared/models/verdict.dart';
import 'package:universal_io/io.dart';

abstract interface class IDioClient {
  Future<IVerdict<dynamic>> get({
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

  Future<IVerdict<dynamic>> fetch({required RequestOptions requestOptions});

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
  Future<IVerdict<dynamic>> get({
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
  Future<IVerdict<dynamic>> fetch({
    required RequestOptions requestOptions,
  }) async {
    try {
      final response = await _client.fetch(requestOptions);
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
      final headers = {HttpHeaders.acceptEncodingHeader: '*'};
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
}
