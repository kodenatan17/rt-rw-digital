import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pasconnect/core/commons/components/atoms/loading/loading_spinner.dart';

class BaseDialogUtils {
  static GlobalKey loadingKey = GlobalKey();
  static GlobalKey loadingKey2 = GlobalKey();

  static dismissLoading() {
    (loadingKey.currentContext ?? loadingKey2.currentContext)?.pop();
  }

  static showLoading(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        key: loadingKey.currentContext == null
            ? loadingKey
            : loadingKey2.currentContext == null
            ? loadingKey2
            : null,
        canPop: false,
        child: const Center(child: LoadingSpinner(size: 50)),
      ),
    );
  }
}
