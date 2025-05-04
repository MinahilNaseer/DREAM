import 'package:dream/screens/dysgraphia_report.dart';
import 'package:dream/screens/initialpage.dart';
import 'package:dream/screens/mainmenu.dart';
import 'package:dream/screens/profilepage.dart';
import 'package:dream/screens/registerpage.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/material.dart';
import 'package:dream/screens/dyscalculia.dart';
import 'package:dream/screens/dysgraphia.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dream/screens/loginpage.dart'; 
import 'package:dream/screens/helppage.dart';
import 'package:dream/screens/editpage.dart';
import 'package:dream/game/gamemainscreen.dart';
import 'package:dream/screens/dyscalculia_report.dart';
import 'package:dream/screens/reportpage.dart';
import 'package:dream/screens/dyslexia_report.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  try {
    await dotenv.load(fileName: ".env");  
  } catch (e) {
    print("Error loading .env file: $e");  
  }
  await Firebase.initializeApp(); 
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
        '/': (context) => const InitialPage(), 
        //'/mainmenu': (context) => MainMenu(), 
        //'/profile': (context) => ProfilePage(), 
        '/register': (context) => const RegisterPage(), 
        '/login': (context) => const LoginPage(), 
        '/help': (context) => const HelpPage(), 
        //'/edit': (context) => const EditProfilePage(),
        '/dyscalculia': (context) => DyscalculiaLevel(),
        '/dysgraphia': (context) => DysgraphiaScreen(),
        '/gameMainScreen': (context) => GameMainScreen(),
          '/reports': (context) => const ReportSelectionPage(),
        '/dyscalculia_report': (context) => const DyscalculiaReportPage(),
        '/dysgraphia_report':(context) => const DysgraphiaReportPage(),
        '/dyslexia_report' :(context) => const DyslexiaReportPage(),
      },

    );
  }
}
