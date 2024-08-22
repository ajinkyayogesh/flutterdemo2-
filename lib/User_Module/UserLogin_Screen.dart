import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/AdminLogin_Screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Admin_Module/Activity/DashbordScreen/MenuScreen.dart';
import '../Utility/ShowSnackBar.dart';
import '../Comman_Classes/WebApis_List.dart';
import 'UserRentDetailsScreen.dart';

class UserLogin_Screen extends StatefulWidget {
  const UserLogin_Screen({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<UserLogin_Screen> {
  @override
  void initState() {
    super.initState();

    _checkNotificationPermissionAndSetup();
  }

  late String Token;
  final TextEditingController emailtext = TextEditingController();
  final TextEditingController passwordtext = TextEditingController();

  Future<void> apiUserLogin(String username, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Login Processing..."),
              ],
            ),
          ),
        );
      },
    );


    final dio = Dio();

    try {
      final response = await dio.post(
        WebApis_List.Api_User_Login,
        data: {
          'username': username,
          'password': password,



        },
      );
      Map<String, dynamic> jsonData = jsonDecode(response.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        final data = response.data;

        print('CheckStatus ${response.data}');
        if (data['status'] == "success") {
          Navigator.of(context).pop();
          Map<String, dynamic> userData = jsonData['data'];
          int userId = userData['user_id'];
          int admin_id = userData['admin_id'];

          // Extract user_id from the data section


          // Store user_id in SharedPreferences
          await storeUserId(userId);
          await storeAdmin_id(admin_id);

          await CheckLogin("User Login");
          // print('CheckStatus userId');
          // Print the user_id



          print('CheckStatus Login successful');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserRentDetailsScreen()),
          );
          // Handle successful login
        } else {

          _showAlertDialog(context,"Message",data['message']);
          print('CheckStatus Login failed: ${data['message']}');
          // Handle login failure
        }
      } else {

        print('CheckStatus Server error: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      print('CheckStatus Error: $e');
    }
  }
  Future<void> storeUserId(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }
  Future<void> storeAdmin_id(int admin_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('admin_id', admin_id);
  }
  Api_User_login() async {
    if (emailtext.text.length == 0) {
      ShowSnackBar.showToast(context, "Enter User Name");
    } else if (passwordtext.text.length == 0) {
      ShowSnackBar.showToast(context, "Enter Password");
    } else {
      apiUserLogin(emailtext.text, passwordtext.text);
      print('Post created: ${WebApis_List.Api_User_Login}');
      print('Post created: ${emailtext.text + passwordtext.text}');
      print('Post Token: ${Token}');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userame', emailtext.text);
      await prefs.setString('password', passwordtext.text);

      //requestPermission();
      /*Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IntroPage()),
      );*/
    }
  }
  Future<String> getFirebaseToken() async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    // Request permission for notifications if not granted
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the token
    Token = (await _firebaseMessaging.getToken())!;

    if (Token != null) {
      print('Firebase Token: $Token');
      return Token;
    } else {
      print('Firebase Token is null');
      return '';
    }

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(),
            Container(
              padding: EdgeInsets.only(left: 35, top: 125),
              child: Text(
                ' Welcome\n User',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        children: [
                          TextField(
                            controller: emailtext,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Email/Username",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          TextField(
                            controller: passwordtext,
                            obscureText: true,
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Api_User_login();
                            },
                            child: Text('Submit'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                              minimumSize: Size(150, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminLogin_Screen(),
                                ),
                              );
                            },
                            child: Text(
                              'Admin Login',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color(0xff4c505b),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
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

  Future<void> CheckLogin(String USerLoginType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USerLoginType', USerLoginType);
  }
  Future<void> subscription_endDAte(String subscription_end) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_end', subscription_end);
  }
  Future<void> name(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }
  Future<void> phone_number(String phone_number) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phone_number);
  }
  Future<void> address(String address) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('address', address);
  }
  Future<void> _checkNotificationPermissionAndSetup() async {
    // Check notification permission status
    PermissionStatus permissionStatus = await Permission.notification.status;

    if (permissionStatus.isDenied ) {
      // Request permission if not granted
      permissionStatus = await Permission.notification.request();

      if (permissionStatus.isGranted) {
        getFirebaseToken();
      } else {
        // Handle the case if permission is denied permanently or user clicks on decline
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Notification Permission Required'),
            content: Text('Please grant notification permissions to receive notifications.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  getFirebaseToken();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    } else {


      getFirebaseToken();


    }
  }
}
