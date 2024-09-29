import 'package:dream/screens/loginpage.dart';
import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/icon_app.png',
                    height: 60,
                  ),
                  const SizedBox(width: 8),
                  
                  const Text(
                    'DREAM',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  const Text(
                    "Shape Brighter Futures with Early Assessment!!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Identify learning challenges early through engaging activities that support your child's growth.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/children_learning.png',
                height: 300, 
                fit: BoxFit.contain, 
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity, 
                height: 50, 
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      _createRoute(),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), 
          ],
        ),
      ),
    );
  }
}
Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); 
        const end = Offset.zero; 
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
