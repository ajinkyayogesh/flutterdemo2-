import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houserantapp/Comman_Classes/AboutUs.dart';
import 'package:houserantapp/User_Module/UserLogin_Screen.dart';
import 'package:houserantapp/User_Module/ShowUserComplaintsList.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Comman_Classes/DatabaseHelper.dart';

import '../Comman_Classes/Profile.dart';
import '../Admin_Module/Model/RentDetail.dart';
import '../Comman_Classes/WebApis_List.dart';
import 'AnnouncementList.dart';
import 'UserComplents.dart';

class UserRentDetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<UserRentDetailsScreen> {
  late Future<List<RentDetail>> futureRentDetails;

  @override
  void initState() {
    super.initState();
    futureRentDetails = fetchAndStoreRentDetails();
  }

  Future<List<RentDetail>> fetchAndStoreRentDetails() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userid = prefs.getInt('user_id');

    print('Stored User ID: $userid');

    try {
      final response = await Dio().post(WebApis_List.Api_User_rentDetails, data: {'user_id': userid});
      print('getDataAdmin: ${response.data}');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        DatabaseHelper dbHelper = DatabaseHelper();
        for (var item in data) {
          RentDetail rentDetail = RentDetail.fromJson(item);
          await dbHelper.insertRentDetail(rentDetail);
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    // Fetch the stored rent details from the database after inserting the new data
    return DatabaseHelper().fetchRentDetails(userid!);
  }

  Future<void> CheckLogin(String nologinfound) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USerLoginType', nologinfound);
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to Logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await CheckLogin("nologinfound");

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLogin_Screen()),
                ); // Close the dialog
                // Add logic to exit the app
                // SystemNavigator.pop(); // Uncomment this line to exit the app
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    _showExitConfirmationDialog(context);
  }

  Future<bool> _onWillPop() async {
    // Show a confirmation dialog
    return (await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Do you really want to exit?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // User does not want to exit
              },
            ),
            TextButton(
              child: Text('Exit'),
              onPressed: () {
                SystemNavigator.pop(); // User wants to exit
              },
            ),
          ],
        );
      },
    )) ?? false; // Default to false if dialog is dismissed by tapping outside
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rent Details', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(),
                  ),
                );
              },
              tooltip: 'Profile',
            ),
            IconButton(
              icon: Image.asset('assets/images/logout.png', height: 30, width: 30),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.brown,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/houserant.jpg'),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Ajinkya Bayas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Home'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserRentDetailsScreen()),
                  );
                },
              ),
              ListTile(
                title: Text('Announcement'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnnouncementList()),
                  );
                },
              ),
              ListTile(
                title: Text('User Complaints'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserComplaints()),
                  );
                },
              ),
              ListTile(
                title: Text('Complaints List'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShowUserComplaintsList()),
                  );
                },
              ),
              ListTile(
                title: Text('Help'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUs()),
                  );
                },
              ),
              ListTile(
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                },
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  _showExitConfirmationDialog(context);
                },
              ),
              ListTile(
                title: Text('Close App'),
                onTap: () {
                  _onWillPop();
                },
              ),
            ],
          ),
        ),
        body: FutureBuilder<List<RentDetail>>(
          future: futureRentDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No Rent Details found.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final rentDetail = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${rentDetail.status}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: rentDetail.status == 'Paid'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Rent Amount: ₹${rentDetail.rentAmount}',
                              style: TextStyle(fontSize: 15, color: Colors.black),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Light Bill Amount: ₹${rentDetail.lightBillAmount}',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rent Received On: ${rentDetail.rentReceivedOn}',
                              style: TextStyle(fontSize: 13, color: Colors.black),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Comment: ${rentDetail.comment}',
                              style: TextStyle(fontSize: 12, color: Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}