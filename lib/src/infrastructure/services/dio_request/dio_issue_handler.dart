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

    final int statusCode = error.response!.statusCode!;

    if (statusCode == HttpStatus.forbidden) {
      return Issue.forbidden();
    }

    if (statusCode == HttpStatus.unauthorized) {
      return Issue.authorization();
    }

    if (statusCode == HttpStatus.unprocessableEntity ||
        statusCode == HttpStatus.badRequest) {
      final message = _dioMessageParser(error);
      return Issue.badRequest(message);
    }

    return _unknownError(error: error);
  }

  IIssue _unknownError({required DioException error}) {
    final String dioError = error.type.toString();
    final int statusCode = error.response?.statusCode ?? 520;

    final String? message = _dioMessageParser(error);
    final String defaultMessage = "[$statusCode] $dioError";

    return Issue.other(
      message ?? defaultMessage,
      layer: IssueLayer.request,
      statusCode: statusCode,
    );
  }
}

String? _dioMessageParser(DioException error) {
  if (error.response == null ||
      error.response?.data == null ||
      error.response?.data.runtimeType != String) {
    return null;
  }

  var message = error.response!.data as String;
  message = message.trim();

  return message.isEmpty ? null : message;
}
