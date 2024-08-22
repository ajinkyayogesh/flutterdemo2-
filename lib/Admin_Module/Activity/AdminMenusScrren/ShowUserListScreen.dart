import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/AddUser.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/AdminUserComplents.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/AnnouncementScreen.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/RentDeuesDeatils.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/SelectUserforAddrent.dart';
import 'package:houserantapp/Comman_Classes/AboutUs.dart';
import 'package:houserantapp/Comman_Classes/Profile.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Comman_Classes/Constant.dart';
import '../../../Comman_Classes/DatabaseHelper.dart';
import '../../../Comman_Classes/WebApis_List.dart';
import '../../../User_Module/UserLogin_Screen.dart';
import '../../../Utility/CustomAleartDialog.dart';
import '../../../Utility/NetworkManager.dart';
import '../../../Utility/ProgressDialog.dart';
import '../../../Utility/SharedprefranceController.dart';
import '../../Model/User.dart';
import 'AddRant.dart';
import 'UserActivateDeactivateScreen.dart';
import 'UserDetailsScreen.dart';
 // Import your necessary packages and files

class ShowUserListScreen extends StatefulWidget {
  static String useristore = "";

  @override
  _GetAllRant_USer_DeatilsState createState() => _GetAllRant_USer_DeatilsState();
}

class _GetAllRant_USer_DeatilsState extends State<ShowUserListScreen> {
  final Dio _dio = Dio();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> users = [];

  @override
  void initState() {
    super.initState();

    fetchAndStoreUsers();
  }

  Future<int?> gteAdminId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('admin_id');
  }

  Future<void> fetchAndStoreUsers() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');

    try {
      if (adminId == null) {
        print('Admin ID is not available.');
        return;
      }

      print('Stored User ID: $adminId');

      final response = await Dio().post(WebApis_List.Api_Admin_getAllActiveUserList, data: {'admin_id': adminId});
      print('getDataAdmin: ${response.data}');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];

        for (var item in data) {
          User user = User.fromJson(item);
          await _dbHelper.insertUser(user);
        }

        loadUsers(adminId);
      } else {

        print('Error: ${response.statusCode}');
        CustomAleartDialog.showAlertDialog(context,'Message',response.data['message']);
      }
    } catch (e) {

      print('Error: $e');
    }
  }
  Future<void> loadUsers(int adminId) async {
    final userList = await _dbHelper.fetchUsers(adminId);
    setState(() {
      users = userList;
    });
  }

  Future<void> CheckLogin(String nologinfound) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USerLoginType', nologinfound);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Text(
                'House - PG Rent',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {

                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShowUserListScreen()),
                ); // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('Add User'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddUser()),
                );  // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('Add Rent'),
              onTap: () {

                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectUserforAddrent()),
                ); // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('Control User'),
              onTap: () async {
                // Handle logout logic
                Navigator.pop(context); // Close the drawer
                // Optionally navigate to login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserTabsScreen()),
                );  // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('Announcement'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                // Handle logout logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnnouncementScreen()),
                );  // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('Dues Details'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                // Handle logout logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RentDeuesDeatils()),
                );  // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('User Complaints'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                // Handle logout logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminUserComplents()),
                );  // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                // Handle logout logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );  // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('About Us'),
              onTap: () async {
                // Handle logout logic
                Navigator.pop(context); // Close the drawer
                // Optionally navigate to login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUs()),
                );  // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                // Handle logout logic

                Navigator.pop(context);
                _showExitConfirmationDialog(context);
                // Close the drawer
                // Optionally navigate to login screen
                 // Adjust to your route name
              },
            ),
            ListTile(
              title: Text('Close App'),
              onTap: () async {
                // Handle logout logic
                Navigator.pop(context);
                _onWillPop();

                // Close the drawer
                // Optionally navigate to login screen
                 // Adjust to your route name
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: users.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                DateTime parsedDate = DateTime.parse(user.room_occupied_date);
                return GestureDetector(
                  onTap: () async {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsScreen(user: user),
                        ),
                      );

                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${user.name}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Email: ${user.emailId}',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Room Join Date: ${DateFormat('dd-MMM-yyyy').format(parsedDate)}',
                            style: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Deposit: ₹${user.deposit}',
                            style: TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
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

  Future<void> storeUserId(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userid', userId);
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
                SharedprefranceController.clear();
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
}
