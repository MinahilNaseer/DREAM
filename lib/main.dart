import 'package:dream/screens/initialpage.dart';
import 'package:dream/screens/registerpage.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dream/screens/loginpage.dart'; 
import 'package:dream/screens/helppage.dart';
import 'package:dream/screens/reportpage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'dart:ui';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  try {
    await dotenv.load(fileName: ".env");  
  } catch (e) {
    print("Error loading .env file: $e");  
  }
  await Firebase.initializeApp(); 
   
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DREAM APP',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 225, 225),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialPage(), 
        '/register': (context) => const RegisterPage(), 
        '/login': (context) => const LoginPage(), 
        '/help': (context) => const HelpPage(), 
        '/reports': (context) => const ReportSelectionPage(),

      },

    );
  }
}
