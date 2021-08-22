import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docker_app/helpers/database.dart';
import 'package:docker_app/screens/frontpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Front(),
      //  home: Scaffold(),
      //
      //  theme: new ThemeData(primaryColor: Colors.white70),
      );
  }
    
}
