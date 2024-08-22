import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatelessWidget {
  // Function to launch email client
  Future<void> _launchEmail() async {
    final emailUrl = Uri.encodeFull('mailto:ajinkyayogesh86@gmail.com');
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      throw 'Could not launch $emailUrl';
    }
  }

  // Function to launch phone dialer
  Future<void> _launchPhone() async {
    final phoneUrl = Uri.encodeFull('tel:7020502128');
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [],
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/images/houserant.jpg'),
              ),
              SizedBox(height: 20),
              Text(
                'Ajinkya Yogesh Developer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Our mission is to deliver quality and excellence.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              Divider(
                height: 40,
                thickness: 2,
                color: Colors.teal[300],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'At [Ay Developer], we strive to deliver the best...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),

                    SizedBox(height: 40),
                    Text(
                      'Connect with Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _launchEmail,
                      child: Row(
                        children: [
                          Icon(Icons.email, color: Colors.orangeAccent),
                          SizedBox(width: 10),
                          Text(
                            'ajinkyayogesh86@gmail.com',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _launchPhone,
                      child: Row(
                        children: [
                          Icon(Icons.phone, color: Colors.orangeAccent),
                          SizedBox(width: 10),
                          Text(
                            '7020502128',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}