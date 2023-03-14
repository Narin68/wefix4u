import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'globals.dart';

class MyFirebaseMessaging {
  final BuildContext? context;
  final _messaging = FirebaseMessaging.instance;

  MyFirebaseMessaging(this.context) {
    _messaging.getToken().then((token) async {
      print('Firebase token: $token');
      Globals.fbToken = token ?? '';
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('On background message');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('On open message');
    });
  }
}
