import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AddRant.dart';
import 'package:intl/intl.dart';
import '../../../Comman_Classes/DatabaseHelper.dart';
import '../../Model/RentDetail.dart';
import '../../Model/User.dart';

class UserDetailsScreen extends StatefulWidget {
  final User user;

  // Constructor to receive the user object
  UserDetailsScreen({required this.user});

  @override
  _RentDetailsScreenState createState() => _RentDetailsScreenState();
}

class _RentDetailsScreenState extends State<UserDetailsScreen> {
  final Dio _dio = Dio();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  static String userid = "";
  late Future<List<RentDetail>> futureRentDetails;
  bool isLoading = true;
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
  @override
  void initState()  {
    super.initState();
    futureRentDetails = fetchAndStoreRentDetails();
  }

  Future<List<RentDetail>> fetchAndStoreRentDetails() async {

     final  userId = widget.user.userId;
     userid=widget.user.userId.toString();

    final url = 'https://pg.yogeshbathe.in/rentDetails.php';


    try {
      final response = await Dio().post(url, data: {'user_id': userId});
      print('getDataAdmin: ${response.data}');
      print('userId: $userId');
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
    return DatabaseHelper().fetchRentDetails(userId);
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 6.0,
        centerTitle: true,
        actions: [


        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[100]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<RentDetail>>(
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
                  DateTime parsedDate = DateTime.parse(rentDetail.rentReceivedOn);
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
                              'Rent Received On: ${DateFormat('dd-MMM-yyyy').format(parsedDate)}',
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildIconButton( tooltip: 'Send WhatsApp Message',
                onPressed: () {
                  _callPhone();
                },
                assetImage: 'assets/images/telephone.png'),
            _buildIconButton( tooltip: 'Send WhatsApp Message',
                onPressed: () {
                  _sendSms();
                },
                assetImage: 'assets/images/sms.png'),
            _buildIconButton( tooltip: 'Send WhatsApp Message',
                onPressed: () {
                  _sendEmail();
                },
                assetImage: 'assets/images/gmail.png'),
            _buildIconButton( tooltip: 'Send WhatsApp Message',
              onPressed: () {
                _whatsapp();
              },
              assetImage: 'assets/images/whatsapp.png') // Path to your WhatsApp icon),

          ],
        ),
      ),
    );
  }
  Widget _buildIconButton({
    required String tooltip,
    required void Function() onPressed,
    IconData? icon,
    String? assetImage,
  }) {
    return IconButton(
      icon: assetImage != null
          ? Image.asset(assetImage, width: 40, height: 40) // Adjust width and height as needed
          : Icon(icon, color: Colors.white),
      onPressed: onPressed,
      color: Colors.white,
      tooltip: tooltip,
      splashColor: Colors.white.withOpacity(0.2),
      highlightColor: Colors.transparent,
    );
  }
  /*IconButton _buildIconButton(IconData icon, String tooltip, void Function() onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: Colors.white, // Change icon color to white for contrast
      tooltip: tooltip,
      splashColor: Colors.white.withOpacity(0.2), // Add splash color for better feedback
      highlightColor: Colors.transparent, // Remove highlight color
    );
  }*/
  Future<void> _sendEmail() async {
    final user = widget.user;
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: user.emailId,  // Replace with the recipient's email
      queryParameters: {
        'subject': 'Enter subject!',
        'body': 'Enter body',
      },
    );

    final url = emailUri.toString();

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error sending email: $e');
      // Optionally show an error message to the user
    }
  }



  Future<void> _callPhone()  async {
    final user = widget.user;
    final Uri _phoneUri = Uri(
        scheme: "tel",
        path: user.phoneNumber
    );
    try {
      if (await canLaunch(_phoneUri.toString()))
        await launch(_phoneUri.toString());
    } catch (error) {
      throw("Cannot dial");
    }
  }
  Future<void> _sendSms() async {
    final user = widget.user;
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: user.phoneNumber,  // Ensure phoneNumber is a valid string
    );

    final url = smsUri.toString();

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not send SMS to ${user.phoneNumber}';
      }
    } catch (e) {
      print('Error sending SMS: $e');
      // Optionally show an error message to the user
    }
  }
  Future<void> _whatsapp() async {
    final user = widget.user;
    // Append country code '91' to the phone number
    final String phoneNumberWithCountryCode = '91${user.phoneNumber}';
    final Uri whatsappUrl = Uri.parse(
        'https://wa.me/$phoneNumberWithCountryCode?text=${Uri.encodeComponent(
            "hi")}'
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        throw 'Could not launch $whatsappUrl';
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      // Optionally show an error message to the user
    }
  }
}
