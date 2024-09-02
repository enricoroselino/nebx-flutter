import 'package:flutter/material.dart';

abstract interface class IDialog {
  Future<bool> confirmation(
    String title,
    String content, {
    BuildContext? context,
  });
}

abstract interface class ILoading {
  bool get isVisible;

  void show({
    BuildContext? context,
  });

  void hide({
    BuildContext? context,
  });

  Future<T> wrap<T>(
    Future<T> Function() operation, {
    BuildContext? context,
  });
}
