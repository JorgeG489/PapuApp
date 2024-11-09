import 'package:flutter/material.dart';
import 'SignInScreen.dart';
import 'WelcomeScreen.dart';
import 'settingsScreen.dart';
import 'ScanScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Scanner',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: SignInScreen(),
    );
  }
}
