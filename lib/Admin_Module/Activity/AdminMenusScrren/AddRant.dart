import 'dart:io';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Comman_Classes/WebApis_List.dart';
import '../../../Utility/CustomAleartDialog.dart';
import '../../../Utility/ProgressDialog.dart';
import '../../../Utility/ShowSnackBar.dart';
import '../../Model/User.dart';
import 'ShowUserListScreen.dart';

class AddRant extends StatefulWidget {
  final User user; // Pass user object to this screen

  AddRant({required this.user});

  @override
  _AddRantState createState() => _AddRantState();
}

class _AddRantState extends State<AddRant> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _lightBillAmountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final Dio _dio = Dio();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _submitRentDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userid = prefs.getInt('userid');

    try {
      final response = await _dio.post(
        WebApis_List.Api_Admin_insertRent,
        data: {
          'user_id': userid,
          'rent_received_on': _dateController.text,
          'rent_amount': _rentAmountController.text,
          'light_bill_amount': _lightBillAmountController.text,
          'comment': _commentController.text,
        },
      );
      print('Response data: ${response.data}');
      print('Response data: ${userid}');
      print('Response data: ${WebApis_List.Api_Admin_insertRent}');
      print('Response data: ${_dateController.text}');
      print('Response data: ${_rentAmountController.text}');
      print('Response data: ${_lightBillAmountController.text}');
      print('Response data: ${_commentController.text}');

      if (response.statusCode == 200 || response.data['status'] == 'success') {
        // Call sharePdf here after successful response



        showAlertDialog(context, "Message", response.data['message']);
      } else {
        showAlertDialog(context, "Message", response.data['message']);
      }
    } catch (e) {
      showAlertDialog(context, "Message", e.toString());
    }
  }

  Future<void> sharePdf() async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Container(
              padding: pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Title
                  pw.Text(
                    'Rent Invoice',
                    style: pw.TextStyle(
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Invoice Details
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Date: ${_dateController.text}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'Invoice #: 123456', // Example invoice number
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    ' ${widget.user.username}',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Rent Amount
                  pw.Text(
                    'Rent Amount: ${_rentAmountController.text}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Light Bill Amount
                  pw.Text(
                    'Light Bill Amount: ${_lightBillAmountController.text}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Comment
                  pw.Text(
                    'Comment: ${_commentController.text}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Footer
                  pw.Align(
                    alignment: pw.Alignment.bottomRight,
                    child: pw.Text(
                      'Thank you for your payment!',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save the PDF file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/invoice.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share the PDF file
      await Share.shareFiles([file.path], text: 'Here is your invoice PDF.');
    } catch (e) {
      print('Error generating or sharing PDF: $e');
      showAlertDialog(context, "Error", "An error occurred while generating or sharing the PDF.");
    }
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Image.asset(
                'assets/images/houserant.jpg',
                width: 40,
                height: 40,
              ),
              SizedBox(width: 10),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: Text('OK'),
              onPressed: () {
                _dateController.clear();
                _rentAmountController.clear();
                _lightBillAmountController.clear();
                _commentController.clear();
                Navigator.of(context).pop();
              },
            ),
        TextButton(
        style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        ),
        child: Text('Share Invoice'),
        onPressed: () async {
          await sharePdf();

        },
        ),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User Rent', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name: ${widget.user.username}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today, color: Colors.brown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _rentAmountController,
                    decoration: InputDecoration(
                      labelText: 'Enter Room Rent',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _lightBillAmountController,
                    decoration: InputDecoration(
                      labelText: 'Enter Light Bill Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Enter Comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitRentDetails,
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.brown,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
