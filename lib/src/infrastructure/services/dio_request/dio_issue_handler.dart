import 'package:dio/dio.dart';
import 'package:nebx/src/infrastructure/services/dio_request/constants/http_status_codes.dart';
import 'package:nebx_verdict/nebx_verdict.dart';

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
        return Issue.timeout(HttpStatusCode.connectionTimedOut);
      case DioExceptionType.sendTimeout:
        return Issue.timeout();
      case DioExceptionType.receiveTimeout:
        return Issue.timeout();
      case DioExceptionType.connectionError:
        return Issue.timeout(HttpStatusCode.gatewayTimeout);
      case DioExceptionType.cancel:
        return Issue.requestCancelled();
      default:
        return _unknownError(error: error);
    }
  }

  IIssue _badResponseError({required DioException error}) {
    if (error.type != DioExceptionType.badResponse) {
      return _unknownError(error: error);
    }

    final int? statusCode = error.response?.statusCode;

    if (statusCode == HttpStatusCode.forbidden) {
      return Issue.forbidden();
    }

    if (statusCode == HttpStatusCode.unauthorized) {
      return Issue.authorization();
    }

    if (statusCode == HttpStatusCode.unprocessableEntity ||
        statusCode == HttpStatusCode.badRequest) {
      final message = _dioMessageInitializer(error);
      return Issue.badRequest(message);
    }

    return _unknownError(error: error);
  }

  IIssue _unknownError({required DioException error}) {
    final String dioError = error.type.toString();
    final int statusCode = error.response?.statusCode ?? HttpStatusCode.unknown;

    final String? message = _dioMessageInitializer(error);
    final String defaultMessage = "[$statusCode] $dioError";

    return Issue.other(
      message ?? defaultMessage,
      layer: IssueLayer.request,
      statusCode: statusCode,
    );
  }
}

String? _dioMessageInitializer(DioException error) {
  // should handle if the server returns a string data
  // for a validation purpose

  if (error.response == null ||
      error.response?.data == null ||
      error.response?.data.runtimeType != String) {
    return null;
  }

  final message = error.response!.data as String;
  return message.trim().isEmpty ? null : message;
}
