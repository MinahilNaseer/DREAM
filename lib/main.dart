import 'package:dream/screens/initialpage.dart';
import 'package:dream/screens/mainmenu.dart';
import 'package:dream/screens/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:dream/screens/dyscalculia.dart';
import 'package:dream/screens/dysgraphia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");  // ✅ Explicitly specify .env
  } catch (e) {
    print("Error loading .env file: $e");  // ✅ Debugging
  }
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
        '/dyscalculia':(context)=>DyscalculiaLevel(),
        '/dysgraphia':(context)=>DysgraphiaScreen()
      },
    );
  }
}

