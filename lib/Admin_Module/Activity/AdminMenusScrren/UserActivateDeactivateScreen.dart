
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houserantapp/User_Module/UserLogin_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Comman_Classes/DatabaseHelper.dart';

import '../../../Comman_Classes/WebApis_List.dart';
import '../../../Utility/ProgressDialog.dart';
import '../../Model/User.dart';
import 'UserDetailsScreen.dart';

class UserTabsScreen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<UserTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('User Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          controller: _tabController,
          tabs: [
            Tab(text: 'Active Users'),
            Tab(text: 'Deactivated Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActiveUsersTabState(),
          DeactivatedUsersScreen(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _ActiveUsersTabState extends StatefulWidget {
  @override
  _GetAllRentUserDetailsState createState() => _GetAllRentUserDetailsState();
}

class _GetAllRentUserDetailsState extends State<_ActiveUsersTabState> {
  final Dio _dio = Dio();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
    // fetchAndStoreUsers();
  }

  Future<void> loadUsers() async {
    final userList = await _dbHelper.fetchactiveUsers();
    setState(() {
      users = userList;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return  Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  users.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to detail screen and pass the user object
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailsScreen(user: user),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.all(12),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name: ${user.name}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Mobile: ${user.phoneNumber}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.brown),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Email: ${user.emailId}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.orange),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Join Date: ${user.room_occupied_date}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    var connectivityResult =
                                    await Connectivity()
                                        .checkConnectivity();

                                    if (connectivityResult ==
                                        ConnectivityResult.mobile ||
                                        connectivityResult ==
                                            ConnectivityResult.wifi) {
                                      // Internet connection is available
                                      // Perform your fetch operation here, e.g., fetchUsersFromAPI()
                                      // Replace with your actual logic to fetch users
                                      // Simulating a delay to fetch data (replace with actual API call)
                                      activateUser(user.userId.toString());
                                    } else {
                                      // No internet connection available
                                      // Handle this case as per your application's requirements
                                      print('No internet connection');
                                      _showToast(context,
                                          "No Internet Connection");
                                      // You can show a snackbar, toast, or alert to inform the user
                                    }

                                    // Handle deactivate user action
                                    // deactivateUser(user.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.deepOrange, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                  ),
                                  child: Text('Deactivate'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

    );
  }
  Future<void> activateUser(String userId) async {
    final DatabaseHelper _dbHelper = DatabaseHelper();
    ProgressDialog.show(context, "User DeActivated Wait..");
     // Replace with actual API URL
    print('ApiLogCheck: $userId');
    try {
      final response = await _dio.post(WebApis_List.Api_Admin_deActivateUser, data: {'user_id': userId});
      final data = response.data;
      print('ApiLogCheck: $response.data');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        ProgressDialog.hide(context);
        setState(() {
          _showAlertDialog(context, "Message", "User DeActivate Sucessfully.");

          _dbHelper.updateUserStatus(userId,0);
          //users.removeWhere((user) => user.id == userId);
        });
      } else {
        ProgressDialog.hide(context);
        _showAlertDialog(context, "Message", data['message']);
        throw Exception('Failed to deactivate user');
      }
    } catch (e) {
      print('Error deactivating user: $e');
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
                loadUsers();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showToast(BuildContext context, String message) {
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
                    Navigator.of(context)
                        .pop(false); // User does not want to exit
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
        )) ??
        false; // Default to false if dialog is dismissed by tapping outside
  }
}

class DeactivatedUsersScreen extends StatefulWidget {
  @override
  DeactivatedUsersScreenState createState() => DeactivatedUsersScreenState();
}

class DeactivatedUsersScreenState extends State<DeactivatedUsersScreen> {
  final Dio _dio = Dio();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      // users = fetchedData;
      isLoading = false;
    });
    fetchAndStoreUsers();
  }

  Future<int?> gteAdminId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('admin_id');
  }

  Future<void> fetchAndStoreUsers() async {
    // ProgressDialog.show(context,"SyncData Wait...");


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
          if (user.isActive == 0) {
            await _dbHelper.insertUser(user);
          }
        }

        loadUsers();
        //ProgressDialog.hide(context);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> loadUsers() async {
    final userList = await _dbHelper.fetchInactiveUsers();
    setState(() {
      users = userList;
    });
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

  Future<void> CheckLogin(String nologinfound) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USerLoginType', nologinfound);
  }

  void _logout() {
    _showExitConfirmationDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return  Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                users.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to detail screen and pass the user object
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailsScreen(user: user),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.all(12),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name: ${user.name}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Mobile: ${user.phoneNumber}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.brown),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Email: ${user.emailId}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.orange),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Join Date: ${user.room_occupied_date}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: ElevatedButton(
                                onPressed: () async {
                                  var connectivityResult =
                                  await Connectivity()
                                      .checkConnectivity();

                                  if (connectivityResult ==
                                      ConnectivityResult.mobile ||
                                      connectivityResult ==
                                          ConnectivityResult.wifi) {
                                    // Internet connection is available
                                    // Perform your fetch operation here, e.g., fetchUsersFromAPI()
                                    // Replace with your actual logic to fetch users
                                    // Simulating a delay to fetch data (replace with actual API call)
                                    deactivateUser(user.userId.toString());
                                  } else {
                                    // No internet connection available
                                    // Handle this case as per your application's requirements
                                    print('No internet connection');
                                    _showToast(context,
                                        "No Internet Connection");
                                    // You can show a snackbar, toast, or alert to inform the user
                                  }

                                  // Handle deactivate user action
                                  // deactivateUser(user.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                ),
                                child: Text('Activate'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
  Future<void> deactivateUser(String userId) async {
    final DatabaseHelper _dbHelper = DatabaseHelper();

    ProgressDialog.show(context, "User Activated Wait..");
     // Replace with actual API URL
    print('ApiLogCheck: $userId');
    try {
      final response = await _dio.post(WebApis_List.Api_Admin_ActivateUser, data: {'user_id': userId});
      final data = response.data;
      print('ApiLogCheck: $response.data');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        ProgressDialog.hide(context);
        setState(() {
          _showAlertDialog(context, "Message", "User Activate Sucessfully.");

          _dbHelper.updateUserStatus(userId,1);
          //users.removeWhere((user) => user.id == userId);
        });
      } else {
        ProgressDialog.hide(context);
        _showAlertDialog(context, "Message", data['message']);
        throw Exception('Failed to deactivate user');
      }
    } catch (e) {
      print('Error deactivating user: $e');
    }
  }

  void _showToast(BuildContext context, String message) {
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
                loadUsers();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
