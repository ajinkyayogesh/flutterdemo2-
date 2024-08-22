import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:houserantapp/FirebaseMessagingService.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Comman_Classes/SplashScreen.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Firebase Handling a background message: ${message.data}');
}

Future<String> getFirebaseToken() async {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // Request permission for notifications if not granted
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Get the token
  String? token = await _firebaseMessaging.getToken();

  if (token != null) {
    print('Firebase Token: $token');
    return token;
  } else {
    print('Firebase Token is null');
    return '';
  }

}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}
