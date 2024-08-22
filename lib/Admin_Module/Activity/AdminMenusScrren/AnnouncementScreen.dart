import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Comman_Classes/WebApis_List.dart';

class AnnouncementScreen extends StatefulWidget {
  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final TextEditingController _announcementController = TextEditingController();
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _announcementController.dispose();
    super.dispose();
  }

  Future<void> _addAnnouncement() async {
    /*  final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');

    if (_announcementController.text.isNotEmpty && adminId != null) {
      // Prepare the data
      final String announcementText = _announcementController.text;
      final Map<String, dynamic> requestData = {
        "admin_id": adminId.toString(),
        "announcement": announcementText,
      };
      print('response.data: $adminId.toString()');
      print('response.data: $announcementText');
      try {
        // Initialize Dio
        final dio = Dio();

        // Make the API call
        final response = await dio.post(
          'https://pg.yogeshbathe.in/sendAnnouncement.php',
          data: requestData,
        );

        // Check if the request was successful
        if (response.statusCode == 200) {
          final responseData = response.data;
          print('response.data: $response.data');
          if (response.statusCode == 200 && response.data['status'] == 'Success') {
            // Update local state
            setState(() {
              _announcements.add(announcementText);
              _announcementController.clear();
            });

            // Show success dialog
            _showSuccessDialog(context);
          } else {
            // Handle failure case
            _showErrorDialog(context, 'Failed to add announcement.');
          }
        } else {
          // Handle HTTP errors
          _showErrorDialog(context, 'Failed to communicate with the server.');
        }
      } catch (e) {
        // Handle network errors
        _showErrorDialog(context, 'An error occurred. Please try again.');
      }
    } else {
      _showErrorDialog(context, 'Please enter an announcement and ensure admin ID is available.');
    }*/


    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');

    if (_announcementController.text.isNotEmpty && adminId != null) {
      final String announcementText = _announcementController.text;
      final Map<String, dynamic> requestData = {
        "admin_id": adminId.toString(),
        "announcement": announcementText,
      };
      print('response.data: $adminId.toString()');
      print('response.data: $announcementText');
      String url = 'https://pg.yogeshbathe.in/sendAnnouncement.php';
      print('response.data: $url');
      try {
        final dio = Dio();
        final response = await dio.post(
          'https://pg.yogeshbathe.in/sendAnnouncement.php',
          data: requestData,
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          print('response.data: $responseData');
          if (response.statusCode == 200 &&
              response.data['status'] == 'success') {
            _announcementController.clear();
            _fetchAnnouncements(); // Refresh the announcements list
            _showSuccessDialog(context);
          } else {
            _showErrorDialog(context, 'Failed to add announcement.');
          }
        } else {
          _showErrorDialog(context, 'Failed to communicate with the server.');
        }
      } catch (e) {
        _showErrorDialog(context, 'An error occurred. Please try again.');
      }
    } else {
      _showErrorDialog(context,
          'Please enter an announcement and ensure admin ID is available.');
    }
  }

  Future<void> _fetchAnnouncements() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');


    if (adminId != null) {
      setState(() {
        _isLoading = true;
      });


      final dio = Dio();

      try {
        final response = await dio.post(WebApis_List.Api_Admin_getAnnouncement,
            data: {'admin_id': adminId.toString()});

        print('response.data: ${response.data}'); // Debug the response

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['status'] == 'success') {
            final List<
                dynamic> responseData = data['data']; // Adjust based on actual response structure
            setState(() {
              _announcements = responseData.map((item) =>
              {
                'announcement': item['announcement'],
                'created_date': item['created_date'],
              }).toList();
              _isLoading = false;
            });
          } else {
            _showErrorDialog(context, 'Failed to fetch announcements.');
          }
        } else {
          _showErrorDialog(context, 'Unexpected response format.');
        }
      } catch (e) {
        print('Error: $e'); // Print error details for debugging
        _showErrorDialog(
            context, 'An error occurred while fetching announcements.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements(); // Load announcements when the screen initializes
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Announcement added successfully.'),
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Announcement',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Create Announcement'),
              Tab(text: 'Announcement List'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Create Announcement Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _announcementController,
                        decoration: InputDecoration(
                          labelText: 'Enter Announcement',
                          labelStyle: TextStyle(color: Colors.brown),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 3,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _addAnnouncement,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        // Blue color for the button
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                        textStyle: TextStyle(
                            fontSize: 16.0, color: Colors.white),
                      ),
                      child: Text('Add Announcement'),
                    ),
                  ],
                ),
              ),
            ),
            // Announcement List Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _announcements.isEmpty
                  ? Center(child: Text('No announcements yet.',
                  style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                itemCount: _announcements.length,
                itemBuilder: (context, index) {
                  final announcement = _announcements.reversed.toList()[index];
                  final DateFormat dateFormat = DateFormat('dd-MMM-yyyy');
                  final DateTime date = DateTime.parse(
                      announcement['created_date'] ??
                          DateTime.now().toIso8601String());
                  final String formattedDate = dateFormat.format(date);

                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        announcement['announcement'] ?? '',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      subtitle: Text(
                        formattedDate, // Display formatted date
                        style: TextStyle(color: Colors.brown),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}