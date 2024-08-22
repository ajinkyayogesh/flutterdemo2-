import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Utility/DioException.dart';





class ApiService {


  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-base-url.com',
       headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Check for internet connectivity
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Show message dialog
  void showMessageDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Handle GET request
  Future<Response?> getRequest(String endpoint, BuildContext context,
      {Map<String, dynamic>? queryParameters}) async {
    if (await isConnected()) {
      try {
        Response response = await _dio.get(
            endpoint, queryParameters: queryParameters);
        _handleResponse(context, response);
        return response;
      } catch (e) {

        return null;
      }
    } else {
      showMessageDialog(
          context, "No Internet", "Please check your internet connection.");
      return null;
    }
  }

  // Handle POST request
  Future<Response?> postRequest(String endpoint, BuildContext context,
      {Map<String, dynamic>? data}) async {
    if (await isConnected()) {
      try {
        Response response = await _dio.post(endpoint, data: data);
        _handleResponse(context, response);
        return response;
      } catch (e) {

        return null;
      }
    } else {
      showMessageDialog(
          context, "No Internet", "Please check your internet connection.");
      return null;
    }
  }

  // Handle response codes
  void _handleResponse(BuildContext context, Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        showMessageDialog(context, "Success", "Request successful.");
        break;
      case 400:
        showMessageDialog(context, "Bad Request", "Invalid request.");
        break;
      case 401:
        showMessageDialog(context, "Unauthorized", "You are not authorized.");
        break;
      case 403:
        showMessageDialog(context, "Forbidden", "Access is forbidden.");
        break;
      case 404:
        showMessageDialog(context, "Not Found", "Resource not found.");
        break;
      case 500:
        showMessageDialog(context, "Server Error", "Internal server error.");
        break;
      default:
        showMessageDialog(context, "Error", "Something went wrong.");
    }
  }

  // Handle error scenarios
  void _handleError(BuildContext context, DioException e) {
    if (e.toString() != null) {
      _handleResponse(context, e.toString()! as Response);
    } else {
      showMessageDialog(
          context, "Error", "Network or server issue. Please try again.");
    }

}






}


