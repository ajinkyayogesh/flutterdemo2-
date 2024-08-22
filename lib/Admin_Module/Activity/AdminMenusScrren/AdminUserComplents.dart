import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Comman_Classes/WebApis_List.dart';

class AdminUserComplents extends StatefulWidget {
  @override
  _AdminusercomplentsState createState() => _AdminusercomplentsState();
}

class _AdminusercomplentsState extends State<AdminUserComplents> {
  late Future<List<dynamic>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _loadComplaints(); // Initialize Future here
  }

  Future<List<dynamic>> _loadComplaints() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? admin_id = prefs.getInt('admin_id');
      if (admin_id != null) {
        return await _fetchUserComplaints(admin_id);
      } else {
        return Future.error('User ID not found');
      }
    } catch (e) {
      return Future.error('Failed to load complaints: $e');
    }
  }

  Future<List<dynamic>> _fetchUserComplaints(int admin_id) async {
    final Dio dio = Dio();
    try {
      final response = await dio.post(
        WebApis_List.Api_Admin_getComplaintAdminSide,
        data: {'admin_id': admin_id},
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
            final DateFormat dateFormat = DateFormat('dd-MMM-yyyy'); // Create DateFormat instance

            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                DateTime? createdDate;

                // Parse date string to DateTime object
                try {
                  createdDate = DateTime.parse(complaint['created_date'] ?? '');
                } catch (e) {
                  print('Error parsing date: $e');
                }

                // Format the date
                final formattedDate = createdDate != null ? dateFormat.format(createdDate) : 'No date';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      complaint['name'] ?? 'No name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.0),
                        Text(
                          complaint['complaint'] ?? 'No complaint',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          formattedDate,
                          style: TextStyle(color: Colors.grey[600]),
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