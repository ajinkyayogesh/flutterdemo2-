import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houserantapp/User_Module/UserLogin_Screen.dart';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Subscribtion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Subscription Details', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Your subscription has ended!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Please renew your subscription to continue using the app.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Handle renew subscription action
                    _renewSubscription(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.brown, // Button color
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Renew Subscription'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await CheckLogin("nologinfound");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserLogin_Screen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green, // Button color
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> CheckLogin(String nologinfound) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USerLoginType', nologinfound);
  }

  void _renewSubscription(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ajinkyayogesh86@gmail.com', // Replace with your support email
      query: Uri.encodeFull(
        'subject=Renew Subscription Request&body=Dear Support Team%0D%0A%0D%0A'
            'I would like to renew my subscription. Please provide me with the necessary steps or link to proceed.%0D%0A%0D%0A'
            'Thank you.%0D%0A%0D%0A'
            'Best regards,%0D%0A'
            'User',
      ),
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch email client.'),
        ),
      );
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Do you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Do not exit
            child: Text('No'),
          ),
          TextButton(
            onPressed: () =>  SystemNavigator.pop(), // Exit
            child: Text('Yes'),

          ),
        ],
      ),
    );

    return exit ?? false; // Default to false if dialog is dismissed
  }
}