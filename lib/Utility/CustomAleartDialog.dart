import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAleartDialog
{
  static void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Image.asset(
                'assets/images/houserant.jpg',
                width: 40,
                height: 40,
              ),
              SizedBox(width: 10),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
              ),
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}