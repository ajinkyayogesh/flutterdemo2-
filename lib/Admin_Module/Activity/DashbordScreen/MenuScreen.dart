


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/AddUser.dart';

import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/ShowUserListScreen.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/UserActivateDeactivateScreen.dart';
import 'package:path/path.dart';

import 'package:shared_preferences/shared_preferences.dart';


import '../../../Comman_Classes/AboutUs.dart';
import '../../../User_Module/UserLogin_Screen.dart';
import '../AdminMenusScrren/AdminUserComplents.dart';
import '../AdminMenusScrren/AnnouncementScreen.dart';
import '../../../Comman_Classes/Constant.dart';

import '../../../Comman_Classes/Profile.dart';




import 'package:flutter/services.dart';

import '../AdminMenusScrren/RentDeuesDeatils.dart';

class MenuScreen extends StatefulWidget {
  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Custom logic when the back button is pressed
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
                onPressed: () => SystemNavigator.pop(), // Exit
                child: Text('Yes'),
              ),
            ],
          ),
        );

        return exit ?? false; // Default to false if dialog is dismissed
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'House - PG Rent',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
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
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            children: List.generate(choices.length, (index) {
              return SelectCard(
                choice: choices[index],
                onTap: () {
                  // Handle item tap here
                  print('${choices[index].title} tapped');

                  if (choices[index].title == "User Info") {
                    Constant.GotoScreen = 'UserInfo';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowUserListScreen()),
                    );
                  } else if (choices[index].title == "Add User") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddUser()),
                    );
                  } else if (choices[index].title == "Add Rent") {
                    Constant.GotoScreen = 'AddRent';
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShowUserListScreen()),
                    );
                  } else if (choices[index].title == "Control User") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserTabsScreen()),
                    );
                  } else if (choices[index].title == "Announcement") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnnouncementScreen()),
                    );
                  } else if (choices[index].title == "Dues") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RentDeuesDeatils()),
                    );
                  } else if (choices[index].title == "Profile") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profile()),
                    );
                  } else if (choices[index].title == "About Us") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUs()),
                    );
                  } else if (choices[index].title == "Logout") {
                    _logout(context);
                  }
                  else if (choices[index].title == "User Complaint") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminUserComplents()),
                    );
                  }

                },
              );
            }),
          ),
        ),
      ),
    );
  }

  void _showSubscriptionAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, size: 40.0), // App icon or relevant icon
              SizedBox(width: 16.0),
              Text('Subscription Ended'),
            ],
          ),
          content: Text('Your subscription ends today. Please renew it to continue using the app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
            onPressed: () => Navigator.of(context).pop(true), // Exit
            child: Text('Yes'),
          ),
        ],
      ),
    );

    return exit ?? false; // Default to false if dialog is dismissed

  }

  void _logout(BuildContext context) {
    _showLogoutConfirmationDialog(context);
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    bool? shouldLogout = await showDialog<bool>(
      context: context, // Ensure correct BuildContext here
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to Logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Use dialogContext
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await CheckLogin("nologinfound");
                Navigator.of(dialogContext).pop(true); // Use dialogContext
              },
            ),
          ],
        );
      },
    );

    if (shouldLogout ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserLogin_Screen()),
      );
    }
  }

  Future<void> CheckLogin(String nologinfound) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USerLoginType', nologinfound);
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'User Info', icon: Icons.home),
  Choice(title: 'Add User', icon: Icons.add),
  Choice(title: 'Add Rent', icon: Icons.map),
  Choice(title: 'Control User', icon: Icons.supervised_user_circle_outlined),
  Choice(title: 'Announcement', icon: Icons.notifications),
  Choice(title: 'Dues', icon: Icons.currency_rupee),
  Choice(title: 'Profile', icon: Icons.account_circle),
  Choice(title: 'About Us', icon: Icons.info),
  Choice(title: 'User Complaint', icon: Icons.report_problem),
  Choice(title: 'Logout', icon: Icons.logout),
];

class SelectCard extends StatelessWidget {
  const SelectCard({required this.choice, required this.onTap});

  final Choice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: 14.0, // Adjusted font size for better readability
      fontWeight: FontWeight.w300,
      color: Colors.white,
    );
    return Card(
      color: Colors.blueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5.0,
      child: InkWell(
        onTap: onTap, // Add onTap callback
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(choice.icon, size: 50.0, color: Colors.white),
              SizedBox(height: 15.0),
              Text(choice.title, style: textStyle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

