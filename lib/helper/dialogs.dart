import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.lightGreen.withOpacity(0.7),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showProgressbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const
            //must be wrapped in Center otherwise it will show a big Circle
            Center(child: CircularProgressIndicator()));
  }
}
