import 'package:dream/screens/initialpage.dart';
import 'package:dream/screens/loginpage.dart';
import 'package:dream/screens/mainmenu.dart';
import 'package:dream/screens/registerpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 225, 225),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

