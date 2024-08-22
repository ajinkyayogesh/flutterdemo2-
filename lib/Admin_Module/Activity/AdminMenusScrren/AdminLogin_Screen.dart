import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/ShowUserListScreen.dart';
import 'package:houserantapp/User_Module/UserLogin_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Comman_Classes/WebApis_List.dart';
import '../../../Utility/ShowSnackBar.dart';
import '../DashbordScreen/MenuScreen.dart';
import 'AdminRegistration.dart';

class AdminLogin_Screen extends StatefulWidget {
  const AdminLogin_Screen({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<AdminLogin_Screen> {
  final TextEditingController emailtext = TextEditingController();
  final TextEditingController passwordtext = TextEditingController();

  Api_Admin_login() async {
    if (emailtext.text.length == 0) {

      ShowSnackBar.showToast(context, "Enter User Name");
    } else if (passwordtext.text.length == 0) {
      ShowSnackBar.showToast(context, "Enter Password");

    } else {
      apiAdminLogin(emailtext.text, passwordtext.text);

      print('Post created: ${emailtext.text + passwordtext.text}');
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
                ' Welcome\n Admin',
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
                              Api_Admin_login();
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserLogin_Screen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'User Login',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Color(0xff4c505b),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Handle New Registration logic here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminRegistration(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'New Registration',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Color(0xff4c505b),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
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

  Future<void> apiAdminLogin(String username, String password) async {
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
                Text("Login Processing ..."),
              ],
            ),
          ),
        );
      },
    );





    final dio = Dio();

    try {
      final response = await dio.post(
        WebApis_List.Api_Admin_adminLogin,
        data: {
          'username': username,
          'password': password,
        },
      );
      print('response.data: $username');
      print('response.data: $username');
      print('response.data: $response');
      Map<String, dynamic> jsonData = jsonDecode(response.toString());
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        Navigator.of(context).pop();
        final data = response.data;
        print('CheckStatus ${response.data}');
        if (data['status'] == "success") {
          Map<String, dynamic> userData = jsonData['data'];
          int admin_id = userData['admin_id'];
          String subscription_end = userData['subscription_end'];
          String admin_phone_number = userData['phone_number'];
          String admin_address = userData['address'];
          String admin_name = userData['name'];
          // Extract user_id from the data section


          // Store user_id in SharedPreferences
          await storeUserId(admin_id);
          await name(admin_name);
          await address(admin_address);
          await phone_number(admin_phone_number);
          await subscription_endDAte(subscription_end);
          await CheckLogin("Admin Login");


          print('CheckStatus Login successful');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShowUserListScreen()),
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
  Future<void> storeUserId(int admin_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('admin_id', admin_id);
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
}
