import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../Comman_Classes/WebApis_List.dart';

class AnnouncementList extends StatefulWidget {
  @override
  _AnnouncementListState createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<AnnouncementList> {
  late Future<List<Announcement>> futureAnnouncements;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    futureAnnouncements = fetchAnnouncements();
  }

  Future<List<Announcement>> fetchAnnouncements() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userid = prefs.getInt('user_id');
    int? admin_id = prefs.getInt('admin_id');
    print('AnnouncementApi: $WebApis_List.Api_User_getAnnouncement');
    try {
      final response = await _dio.post(WebApis_List.Api_User_getAnnouncement, data: {'admin_id': admin_id});
      print('AnnouncementApi: $response.data');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        return data.map((item) => Announcement.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching announcements');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Announcement>>(
        future: futureAnnouncements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No announcements available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final announcement = snapshot.data![index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          announcement.description,
                          style: TextStyle(fontSize: 16),
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

class Announcement {
  final String title;
  final String description;

  Announcement({required this.title, required this.description});

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['announcement'] ?? 'No announcement',
      description: json['created_date'] ?? 'No created_date',
    );
  }
}
