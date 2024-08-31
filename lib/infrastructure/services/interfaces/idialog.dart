import 'package:flutter/material.dart';

abstract interface class IDialog {
  Future<bool> confirmation(
    String title,
    String content, {
    BuildContext? context,
  });
}
