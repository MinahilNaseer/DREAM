import 'package:dream/screens/initialpage.dart';
import 'package:dream/screens/mainmenu.dart';
import 'package:dream/screens/profilepage.dart';
import 'package:dream/screens/registerpage.dart'; // Import RegisterPage
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'package:dream/screens/loginpage.dart'; // Ensure this import is present
import 'package:dream/screens/helppage.dart';
import 'package:dream/screens/editpage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DREAM APP',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 225, 225),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialPage(), // Initial Page
        '/mainmenu': (context) => const MainMenu(), // Main Menu
        '/profile': (context) => const ProfilePage(), // Profile Page
        '/register': (context) => const RegisterPage(), // Register Page
        '/login': (context) => const LoginPage(), // This should match the name used in Navigator
        '/help'  :(context) => const HelpPage(), 
        '/edit' :(context) =>  const EditProfilePage()
      },
    );
  }
}
