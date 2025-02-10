import 'package:flutter/material.dart';
import '../widgets/listwidgetprofile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 240, 225, 225), 
        elevation: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple, size: 30,), 
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text(
              'Profile',
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Color(0xFF0D47A1)
            ),),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/boy-pic.png',
                height: 240,
                width: 240,
                fit: BoxFit.contain,
              ),
            ),

            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    
                    CustomListTile(
                      icon: Icons.edit,
                      title: "Edit Personal Information",
                      onTap: () {
                        
                      },
                    ),
                    const Divider(),
                    SizedBox(height: 20,),
                    CustomListTile(
                      icon: Icons.insert_chart_outlined,
                      title: "Reports / Results",
                      onTap: () {
                        
                      },
                    ),
                    const Divider(),
                    SizedBox(height: 20,),
                    CustomListTile(
                      icon: Icons.help_outline,
                      title: "Help",
                      onTap: () {
                        
                      },
                    ),
                    const Divider(),
                    SizedBox(height: 20,),
                    CustomListTile(
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: () {
                        
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
