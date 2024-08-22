import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houserantapp/User_Module/UserLogin_Screen.dart';
import 'package:houserantapp/User_Module/UserRentDetailsScreen.dart';
import 'package:houserantapp/Admin_Module/Activity/AdminMenusScrren/ShowUserListScreen.dart';
import 'dart:async';


import 'package:houserantapp/Admin_Module/Activity/DashbordScreen/MenuScreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Admin_Module/Activity/AdminMenusScrren/Subscribtion.dart';


// Import your screens


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Navigate after a delay
    Timer(Duration(seconds: 3), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? checkLoginType = prefs.getString('USerLoginType');

      if (checkLoginType == "Admin Login") {

        getSubscriptionDate();
        print("User logged in as admin");
      } else if (checkLoginType == "User Login") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserRentDetailsScreen(),
          ),
        );
        print("User logged in with a different type");
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserLogin_Screen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: Image.asset(
                'assets/images/houserant.jpg', // Replace with your logo
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Customer', // Replace with your app name or tagline
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'House-PG Rent', // Optional tagline
              style: TextStyle(
                color: Colors.brown,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> getSubscriptionDate()
  async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subscription_end = prefs.getString('subscription_end');

    if (subscription_end != null) {
      // Parse subscription_end into DateTime
      DateTime? endDateTime = DateTime.tryParse(subscription_end);
      if (endDateTime != null) {
        // Format the date into yyyy-MM-dd
        String subscription_endDateCheck = DateFormat('yyyy-MM-dd').format(endDateTime);
        print("Subscription end date: $subscription_endDateCheck");

        // Get current date in yyyy-MM-dd format
        DateTime currentDateTime = DateTime.now();
        String currantdate = DateFormat('yyyy-MM-dd').format(currentDateTime);
        print("Current date: $currantdate");

        // Parse formatted dates back into DateTime for comparison
        DateTime subscriptionEndDate = DateFormat('yyyy-MM-dd').parse(subscription_endDateCheck);
        DateTime currentDate = DateFormat('yyyy-MM-dd').parse(currantdate);

        // Compare dates
        if (currentDate.isAfter(subscriptionEndDate)) {
          print("subscriptionEndDate $subscriptionEndDate");
          print("subscriptionEndDate $currantdate");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Subscribtion()), // Update with actual screen
          );
          print("The subscription ends after today.");
        } else if (subscriptionEndDate.isAtSameMomentAs(currentDate)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Subscribtion()), // Update with actual screen
          );
          print("The subscription ends today.");
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ShowUserListScreen(), // Update with actual screen
            ),
          );
          print("The subscription does not end today.");
        }
      } else {
        print('Invalid date');
      }
    } else {
      print("No subscription end date found.");
    }




  /*  String subscription_endDateCheck="";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? subscription_end = prefs.getString('subscription_end');
    DateTime? endDateTime = DateTime.tryParse(subscription_end ?? '');
    if (endDateTime != null) {
      subscription_endDateCheck = DateFormat('yyyy-MM-dd').format(endDateTime);
      print(subscription_endDateCheck); // Outputs formatted date
    } else {
      print('Invalid date');
    }
    if (subscription_end != null) {

      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      DateTime currentDate = DateTime.fromMillisecondsSinceEpoch(currentTimestamp);
      String currantdate = DateFormat('yyyy-MM-dd').format(currentDate);
      print("The subscription1$subscription_endDateCheck");
      print("The subscription2$currantdate");
      // Check if the subscription end date is today
      if (subscription_endDateCheck== currantdate) {

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Subscribtion()), // Update with actual screen
        );
        print("The subscription ends today.");
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MenuScreen(),
          ),
        );
        print("The subscription does not end today.");
      }
    } else {
      print("No subscription end date found.");
    }*/
  }
}
