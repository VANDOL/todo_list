import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:work_list/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      home: Homescreen(),
    ),
  );
}
