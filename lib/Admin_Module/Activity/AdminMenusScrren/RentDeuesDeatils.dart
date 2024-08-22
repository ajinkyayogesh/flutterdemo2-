import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Comman_Classes/DatabaseHelper.dart';
import '../../../Comman_Classes/WebApis_List.dart';
import '../../Model/Rent.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

 // Import your Rent model

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

 // Import your Rent model

class RentDeuesDeatils extends StatefulWidget {
  @override
  _RentDeuesDeatilsState createState() => _RentDeuesDeatilsState();
}

class _RentDeuesDeatilsState extends State<RentDeuesDeatils> {
  late Future<List<Rent>> futureRents;

  @override
  void initState() {
    super.initState();
    futureRents = fetchAndStoreUsers().then((_) {
      return DatabaseHelper().getRents(); // Retrieve stored data after fetching and storing
    }).catchError((error) {
      print('Error fetching and storing data: $error');
      return Future.value([]);
    });
  }

  Future<void> fetchAndStoreUsers() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');

    try {
      if (adminId == null) {
        print('Admin ID is not available.');
        return;
      }

      final response = await Dio().post(WebApis_List.Api_Admin_duesRent, data: {'admin_id': adminId});
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        List<dynamic> data = response.data['data'];
        final dbHelper = DatabaseHelper();

        var uniqueData = <String, dynamic>{};
        for (var item in data) {
          uniqueData[item['phone_number']] = item;
        }

        for (var item in uniqueData.values) {
          await dbHelper.insertRent(Rent(
            phoneNumber: item['phone_number'],
            name: item['name'],
            paidRent: (item['paid_rent'] as num).toDouble(),
            unpaidRent: (item['unpaid_rent'] as num).toDouble(),
          ));
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rent Due Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [

        ],
      ),
      body: FutureBuilder<List<Rent>>(
        future: futureRents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Number: ${item.phoneNumber}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Paid Rent: ${item.paidRent.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Unpaid Rent: ${item.unpaidRent.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 16,color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.phone, color: Colors.green),
                      onPressed: () => _makePhoneCall(item.phoneNumber),
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