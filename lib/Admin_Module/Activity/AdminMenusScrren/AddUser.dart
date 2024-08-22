import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Comman_Classes/WebApis_List.dart';
import 'ShowUserListScreen.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController phonenumber = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController roomaccupieddate = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // If the form is valid, process the data.
      final name = _nameController.text;
      final email = _emailController.text;
      final phone_number = phonenumber.text;
      final deposit = _depositController.text;
      final usernameinput = username.text;
      final passwordinput = password.text;
      final roomaccupieddateinput = roomaccupieddate.text;

      // Process the data or send it to a server.
      print('Name: $name');
      print('Email: $email');
      print('phone_number: $phone_number');
      print('Deposit: $deposit');
      print('usernameinput: $usernameinput');
      print('passwordinput: $passwordinput');
      print('roomaccupieddateinput: $roomaccupieddateinput');

      // Clear the fields after submission

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? admin_id = prefs.getInt('admin_id');


      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
          // Internet is available, you might want to call API here
          print('Internet connection available');
          UserCraeted_Api(
              admin_id.toString(),
              _nameController.text,

              username.text,
              phonenumber.text,
              _emailController.text,
              password.text,
              _depositController.text,
              roomaccupieddate.text,
              "1");
        } else {
          // No internet connection
          _showAlertDialog(context, "Message", "No Internet Connection");
        }
      });

    }
  }

  Future<int?> gteAdminId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('admin_id');
  }

  Future<void> UserCraeted_Api(String adminid, String name, String username,
      String phonenumbeer, String emailid, String password, String deposite,
      String roomaccupieddate, String isactive) async {
    print('InputParam: $adminid');
    print('InputParam: $name');
    print('InputParam: $username');
    print('InputParam: $phonenumbeer');
    print('InputParam: $emailid');
    print('InputParam: $password');
    print('InputParam: $deposite');
    print('InputParam: $roomaccupieddate');
    print('InputParam: $isactive');
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
                Text("User Created Wait ..."),
              ],
            ),
          ),
        );
      },
    );



    final dio = Dio();

    try {
      final response = await dio.post(
        WebApis_List.Api_Admin_createUser,
        data: {
          "admin_id": adminid,
          "name": name,
          "username": username,
          "phone_number": phonenumbeer,
          "email_id": emailid,
          "password": password,
          "deposit": deposite,
          "room_occupied_date": roomaccupieddate,
          "is_active": isactive
        },
      );
      Map<String, dynamic> jsonData = jsonDecode(response.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        final data = response.data;
        print('CheckStatus ${response.data}');
        if (data['status'] == "success") {
          print('User Created  successful');
          _showAlertDialog(context, "Room Rant", "User Created Sucessfully");

          // Handle successful login
        } else {
          _showAlertDialog(context, "Message", data['message']);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowUserListScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: username,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a User Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _selectDate(context); // Open date picker dialog
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: roomaccupieddate,
                      decoration: InputDecoration(
                        labelText: 'Join Room Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a date (DD/MM/YYYY)';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Enter Password',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: phonenumber,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _depositController,
                  decoration: InputDecoration(
                    labelText: 'Deposit',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a deposit amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16), // Space between buttons
                ElevatedButton(
                  onPressed: () {
                    // Add functionality for saving contact
                    _saveContact();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Save Contact button color
                    minimumSize: Size(double.infinity, 50), // Button size
                  ),
                  child: Text('Save Contact'),
                ),
                SizedBox(height: 20), // Extra space before the buttons
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orangeAccent, // Button color
                    minimumSize: Size(double.infinity, 50), // Button size
                  ),
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Add functionality for saving contact

  addPerson () async {
    var newPerson = Contact();

    newPerson.givenName = "FreeZone1";
    newPerson.familyName = "family";
    newPerson.phones = [Item(label: "mobile", value: '702050')];
    // I wrote 'newPerson.phones = [number];' and it was wrong.
    await ContactsService.addContact(newPerson);
    //  adding newPerson
    var contacts = await ContactsService.getContacts();
    //  call all of contacts

    //  to show the contacts directly, I use 'setState'.
  }
  Future<void> _saveContact() async {
  //  addPerson();
    var newPerson = Contact();
    // newPerson uses Contact Package
    newPerson.givenName = 'FreeZone';
    newPerson.phones = [Item(label: "mobile", value: '01752591591')];
    newPerson.emails = [Item(label: "work", value: 'info@34.71.214.132')];

    if (await Permission.contacts.status.isGranted) {
      await ContactsService.addContact(newPerson);
      var contacts = await ContactsService.getContacts();
      print("Contact added successfully");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        roomaccupieddate.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }
}