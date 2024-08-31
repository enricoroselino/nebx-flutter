import 'package:universal_io/io.dart';

abstract interface class IIssue {
  String get message;

  IssueLayer get issueLayer;

  int get statusCode;

  IssueType get issueType;
}

class Issue implements IIssue {
  @override
  final String message;
  @override
  final IssueLayer issueLayer;
  @override
  final int statusCode;
  @override
  final IssueType issueType;

  Issue._(
    this.message,
    this.issueLayer,
    this.issueType, {
    this.statusCode = 0,
  }) {
    if (issueLayer == IssueLayer.app && statusCode != 0) {
      const message =
          "Invalid Issue: Application Issue can't have a status code";
      throw ArgumentError.value(message);
    }

    if (issueLayer == IssueLayer.request && statusCode > 0) {
      const message = "Invalid Issue: Request Issue should have a status code";
      throw ArgumentError.value(message);
    }
  }

  factory Issue.none() => Issue._("", IssueLayer.none, IssueType.none);

  factory Issue.other(
    String error, {
    IssueLayer layer = IssueLayer.app,
    int statusCode = 0,
  }) =>
      Issue._(
        error,
        layer,
        IssueType.other,
        statusCode: statusCode,
      );

  factory Issue.parsing([String? objectName]) {
    final message = "Parsing ${(objectName ?? "data").trim()} failed";

    return Issue._(
      message,
      IssueLayer.app,
      IssueType.parsing,
    );
  }

  factory Issue.forbidden() => Issue._(
        "[${HttpStatus.forbidden}] Forbidden",
        IssueLayer.request,
        IssueType.forbidden,
        statusCode: HttpStatus.forbidden,
      );

  factory Issue.authorization() => Issue._(
        "[${HttpStatus.unauthorized}] Unauthorized",
        IssueLayer.request,
        IssueType.authorization,
        statusCode: HttpStatus.unauthorized,
      );

  factory Issue.timeout([int? statusCode]) => Issue._(
        "[${statusCode ?? HttpStatus.requestTimeout}] Timeout",
        IssueLayer.request,
        IssueType.timeout,
        statusCode: statusCode ?? HttpStatus.requestTimeout,
      );

  factory Issue.server() => Issue._(
        "[${HttpStatus.internalServerError}] Server error",
        IssueLayer.request,
        IssueType.server,
        statusCode: HttpStatus.internalServerError,
      );

  factory Issue.badRequest([String? error]) {
    const defaultMessage = "[${HttpStatus.badRequest}] Bad request";
    final message = (error ?? defaultMessage);

    return Issue._(
      message,
      IssueLayer.request,
      IssueType.badRequest,
      statusCode: HttpStatus.badRequest,
    );
  }

  factory Issue.requestCancelled() => Issue._(
        "[${HttpStatus.clientClosedRequest}] Request cancelled",
        IssueLayer.request,
        IssueType.cancel,
        statusCode: HttpStatus.clientClosedRequest,
      );
}

enum IssueType {
  cancel,
  parsing,
  authorization,
  forbidden,
  timeout,
  badRequest,
  server,
  other,
  none,
}

enum IssueLayer { request, app, none }
