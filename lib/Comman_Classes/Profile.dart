import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  static String useristore = "";

  @override
  Profilestate createState() => Profilestate();
}

class Profilestate extends State<Profile> {
  String? userame;
  String? password;

  String? subscription_end,name,phone_number,address;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userame = prefs.getString('userame') ??
          'Unknown'; // Provide default value if null
      password = prefs.getString('password') ??
          'Unknown'; // Provide default value if null
      subscription_end = prefs.getString('subscription_end') ??
          'Not Available'; // Provide default value if null
      name = prefs.getString('name') ??
          'Not Available'; // Provide default value if null
      phone_number = prefs.getString('phone_number') ??
          'Not Available'; // Provide default value if null
      address = prefs.getString('address') ??
          'Not Available'; // Provide default value if null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/houserant.jpg'),
                ),
              ),
              SizedBox(height: 20),

              // User Name
              Text(
                'House-Pg Rent',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),

              // User Email
              Text(
                userame ?? 'Unknown', // Use null-aware operator
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                password ?? 'Unknown', // Use null-aware operator
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 20),
              // Divider
              Divider(color: Colors.grey.shade300),
              ListTile(
                leading: Icon(Icons.date_range, color: Colors.brown),
                title: Text('Subscription Validation'),
                subtitle: Text(subscription_end ??
                    'Not Available'), // Use null-aware operator
              ),
              // Additional Information Section
              ListTile(
                leading: Icon(Icons.supervised_user_circle_outlined, color: Colors.orange),
                title: Text('User Name'),
                subtitle: Text(name ??
                    'Not Available'),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.orange),
                title: Text("Phone_Number"),
                subtitle: Text(phone_number ??
                    'Not Available'),
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.orange),
                title: Text("Address"),
                subtitle: Text(address ??
                    'Not Available'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
