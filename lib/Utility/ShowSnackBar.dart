import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowSnackBar
{
  static void showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange, // Set the background color here
        action: SnackBarAction(
          label: 'OK',
          onPressed: scaffold.hideCurrentSnackBar,
          textColor: Colors.white, // Set text color for contrast
        ),
      ),
    );
  }
}