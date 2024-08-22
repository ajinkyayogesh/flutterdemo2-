import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Comman_Classes/WebApis_List.dart';

class ShowUserComplaintsList extends StatefulWidget {
  @override
  _ShowUserComplaintsListState createState() => _ShowUserComplaintsListState();
}

class _ShowUserComplaintsListState extends State<ShowUserComplaintsList> {
  late Future<List<dynamic>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _loadComplaints(); // Initialize Future here
  }

  Future<List<dynamic>> _loadComplaints() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');
      if (userId != null) {
        return await _fetchUserComplaints(userId);
      } else {
        return Future.error('User ID not found');
      }
    } catch (e) {
      return Future.error('Failed to load complaints: $e');
    }
  }

  Future<List<dynamic>> _fetchUserComplaints(int userId) async {
    final Dio dio = Dio();
    try {
      final response = await dio.post(
        WebApis_List.Api_User_getComplaintUserSide,
        data: {'user_id': userId},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final responseData = response.data as Map<String, dynamic>;
        // Log the response for debugging
        List<dynamic> data = response.data['data'];
        print('Response Data: $responseData');
        return List<dynamic>.from(responseData['data'] ?? []);
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      // Log the error for debugging
      print('Error fetching complaints: $e');
      throw Exception('Failed to load complaints: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Complaints', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _complaintsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No complaints found'));
          } else {
            final complaints = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(8.0), // Margin around the ListView
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  // Margin for each Card
                  elevation: 4.0,
                  // Shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12.0), // Rounded corners
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0), // Padding inside the Card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint['complaint'] ?? 'No title',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          complaint['created_date'] ?? 'No description',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
