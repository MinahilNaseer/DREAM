import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: SingleChildScrollView( 
          child: Column(
            children: [
              
              Container(
                height: 300, 
                width: MediaQuery.of(context).size.width, 
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 30,
                      child: Image.asset(
                        'assets/images/—Pngtree—hand-painted cartoon images of children_4346171.png', 
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Sign in to continue",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              
              IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
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
                    mainAxisAlignment: MainAxisAlignment.start, 
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
                      const SizedBox(height: 30), 
                      
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email), 
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25), 
                      
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock), 
                          suffixIcon: Icon(Icons.visibility), 
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        obscureText: true, 
                      ),
                      const SizedBox(height: 24), 
                      
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            
                          },
                          child: const Text(
                            'LOG IN',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), 
                      
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                          Text(
                            "Not Registered Yet? ",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                ),
              ),
              SizedBox(height: 90,),
              Image.asset("assets/images/train.png")
            ],
          ),
        ),
      ),
    );
  }
}


