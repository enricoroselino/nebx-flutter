import 'package:dio/dio.dart';
import 'package:nebx_verdict/nebx_verdict.dart';
import 'package:universal_io/io.dart';

abstract interface class IDioIssueHandler {
  IIssue mapIssue({required DioException error});
}

class DioIssueHandler implements IDioIssueHandler {
  @override
  IIssue mapIssue({required DioException error}) {
    switch (error.type) {
      case DioExceptionType.badResponse:
        return _badResponseError(error: error);
      case DioExceptionType.connectionTimeout:
        return Issue.timeout(HttpStatus.networkConnectTimeoutError);
      case DioExceptionType.sendTimeout:
        return Issue.timeout(HttpStatus.requestTimeout);
      case DioExceptionType.receiveTimeout:
        return Issue.timeout(HttpStatus.requestTimeout);
      case DioExceptionType.connectionError:
        return Issue.timeout(HttpStatus.gatewayTimeout);
      case DioExceptionType.cancel:
        return Issue.requestCancelled();
      default:
        return _unknownError(error: error);
    }
  }

  IIssue _badResponseError({required DioException error}) {
    if (error.type != DioExceptionType.badResponse ||
        error.response?.statusCode.runtimeType != int) {
      return _unknownError(error: error);
    }

    // in theory the status code will not null after the check
    final int statusCode = error.response!.statusCode!;

    if (statusCode == HttpStatus.forbidden) {
      return Issue.forbidden();
    }

    if (statusCode == HttpStatus.unauthorized) {
      return Issue.authorization();
    }

    if (statusCode == HttpStatus.unprocessableEntity ||
        statusCode == HttpStatus.badRequest) {
      return Issue.badRequest(error.response?.data);
    }

    return _unknownError(error: error);
  }

  IIssue _unknownError({required DioException error}) {
    final dioError = error.type.toString();
    final statusCode = error.response?.statusCode ?? 520;
    final defaultMessage = "[$statusCode] $dioError";

    return Issue.other(
      error.response?.data ?? defaultMessage,
      layer: IssueLayer.request,
      statusCode: statusCode,
    );
  }
}
