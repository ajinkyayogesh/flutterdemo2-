import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/ShowUserListScreen.dart';

import 'AdminLogin_Screen.dart';


class AdminRegistration extends StatefulWidget {
  @override
  _AdminRegistrationState createState() => _AdminRegistrationState();
}

class _AdminRegistrationState extends State<AdminRegistration> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';


  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  Future<void> _sendOtp() async {
    final phone = phoneController.text.trim();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle error
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },

    );

  }
  // Dio instance
  final Dio _dio = Dio();

  // Function to call the registration API
  Future<void> registerAdmin() async {
    // Prepare the payload
    final data = {
      "name": nameController.text,
      "email_id": emailController.text,
      "phone_number": phoneController.text,
      "username": usernameController.text,
      "password": passwordController.text,
      "address": addressController.text,
    };
    print('RegistrtionApi: ${nameController.text}');
    print('RegistrtionApi: ${emailController.text}');
    print('RegistrtionApi: ${phoneController.text}');
    print('RegistrtionApi: ${usernameController.text}');
    print('RegistrtionApi: ${passwordController.text}');
    print('RegistrtionApi: ${addressController.text}');
    print('RegistrtionApi: ${'https://pg.yogeshbathe.in/adminRegistration.php'}');
    try {
      // Make the POST request
      final response = await _dio.post(
        'https://pg.yogeshbathe.in/adminRegistration.php',
        data: data,
      );

      // Check the response
      if (response.data['status'] == 'Success') {
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text(response.data['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminLogin_Screen(),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Show failure dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(response.data['message'] ?? 'Registration failed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }   catch (e) {
      // Handle Dio exceptions
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('message'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Admin Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Register as Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(nameController, 'Name', Icons.person),
                      SizedBox(height: 10),
                      _buildTextField(emailController, 'Email ID', Icons.email),
                      SizedBox(height: 10),
                      _buildTextField(phoneController, 'Phone Number', Icons.phone),
                      SizedBox(height: 10),
                      _buildTextField(usernameController, 'Username', Icons.account_circle),
                      SizedBox(height: 10),
                      _buildTextField(passwordController, 'Password', Icons.lock, obscureText: true),
                      SizedBox(height: 10),
                      _buildTextField(addressController, 'Address', Icons.location_on),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: registerAdmin,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueAccent, backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField with icon
  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.blue.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
  @override
  void dispose() {
    // Dispose of the controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
