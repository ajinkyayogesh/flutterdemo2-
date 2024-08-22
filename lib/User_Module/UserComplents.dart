import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Comman_Classes/WebApis_List.dart';

class UserComplaints extends StatefulWidget {
  @override
  _UserComplaintsState createState() => _UserComplaintsState();
}

class _UserComplaintsState extends State<UserComplaints> {
  final TextEditingController _complaintController = TextEditingController();
  final Dio _dio = Dio();

  Future<void> _submitComplaint() async {
    final complaint = _complaintController.text;

    if (complaint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a complaint')),
      );
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userid = prefs.getInt('user_id');
    int? admin_id = prefs.getInt('admin_id');

    print('ApiLog: $WebApis_List.Api_User_sendComplaint');
    print('ApiLog: $admin_id');
    print('ApiLog: $userid');
    print('ApiLog: $complaint');

    try {
      final response = await _dio.post(WebApis_List.Api_User_sendComplaint, data: {'complaint': complaint,'admin_id': admin_id,'user_id': userid});
      print('ApiLog: $response.data');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted successfully')),
        );
        _complaintController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit complaint')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Complaint', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'We value your feedback. Please enter your complaint below:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: TextField(
                    controller: _complaintController,
                    decoration: InputDecoration(
                      labelText: 'Enter your complaint',
                      labelStyle: TextStyle(color: Colors.brown),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown, width: 2.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 5,
                    style: TextStyle(color: Colors.brown[800]),
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _submitComplaint,
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, // Button text color
                    padding: EdgeInsets.symmetric(vertical: 19), // Padding inside the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13), // Rounded corners
                    ),
                    elevation: 15, // Shadow effect
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}