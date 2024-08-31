import 'issue.dart';

abstract interface class IVerdict<TSuccess> {
  bool get isSuccess;

  bool get isFailure;

  TSuccess? get data;

  IIssue get issue;
}

class Verdict<TSuccess> implements IVerdict<TSuccess> {
  @override
  final bool isSuccess;

  @override
  bool get isFailure => !isSuccess;
  @override
  final TSuccess? data;
  @override
  final IIssue issue;

  Verdict._(this.isSuccess, this.data, this.issue) {
    if (isSuccess && issue != Issue.none()) {
      throw ArgumentError.value(
          "Invalid Verdict: Successful Verdict cannot have an Issue");
    }

    if (!isSuccess && issue == Issue.none()) {
      throw ArgumentError.value(
          "Invalid Verdict: Failed Verdict must have an Issue");
    }
  }

  factory Verdict.successful([TSuccess? value]) =>
      Verdict._(true, value, Issue.none());

  factory Verdict.failed(IIssue issue) => Verdict._(false, null, issue);
}
