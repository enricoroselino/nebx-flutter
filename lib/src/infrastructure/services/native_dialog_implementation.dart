import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:nebx/src/infrastructure/services/interfaces/idialog.dart';

class NativeDialogImplementation implements IDialog {
  @override
  Future<bool> confirmation(
    String title,
    String content, {
    BuildContext? context,
  }) async {
    final clickedButton = await FlutterPlatformAlert.showAlert(
      windowTitle: title,
      text: content,
      alertStyle: AlertButtonStyle.yesNo,
      iconStyle: IconStyle.question,
    );

    return clickedButton == AlertButton.noButton ? false : true;
  }
}
