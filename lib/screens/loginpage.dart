  import 'package:dream/screens/mainmenu.dart';
  import 'package:dream/screens/registerpage.dart';
  import 'package:dream/u_auth/firebase_auth/firebase_auth_services.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:dream/screens/addchildpage.dart';


  class LoginPage extends StatefulWidget {
    const LoginPage({super.key});
    @override
    _LoginPageState createState() => _LoginPageState();
  }
  class _LoginPageState extends State<LoginPage> {

    final FirebaseAuthService _auth = FirebaseAuthService();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool _isLoading = false;

  @override
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: true, 
        body: SafeArea(
          child: Stack(
            children: [
          SingleChildScrollView( 
            child: Column(
              children: [
                SizedBox(
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
                            const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
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
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email), 
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25), 
                            
                            TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock), 
                                suffixIcon: const Icon(Icons.visibility), 
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              obscureText: true, 
                            ),
                            Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: _showForgotPasswordDialog,
    child: const Text(
      "Forgot Password?",
      style: TextStyle(
        color: Colors.purple,
        fontSize: 14,
        decoration: TextDecoration.underline,
      ),
    ),
  ),
),
                            
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
                                onPressed: _logIn ,
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
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                                const Text(
                                  "Not Registered Yet? ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.push(
                                      context,
                                      _createRoute(const RegisterPage()),
                                      )
                                  },
                                  child:const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.purple,
                                      decoration: TextDecoration.underline
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                      ),
                    ),
                  ),
                ),
                
                Image.asset(
                  "assets/images/writing-dy.png",
                  height: 150,
                  width: 600,
                  )
              ],
            ),
          ),
          if(_isLoading)
        Container(
          color: Colors.black.withOpacity(0.2),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.purple,
            )
          )
        )
            ]
          )
        ),
        
      );
    }
    void _logIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in both email and password.");
      return;
    }

    setState((){
      _isLoading = true;
    });

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);
      if (user != null) {
        print("User successfully Logged In");

        
        QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .get();

        List<QueryDocumentSnapshot> children = childrenSnapshot.docs;

        if (children.isEmpty) {
          setState((){
            _isLoading = false;
          });
          _showError("No child found under this account. Please register at least one.");
          return;
        } 
        setState((){
          _isLoading = false;
        });
        _showChildSelectionDialog(children);
          setState((){
            _isLoading = false;
          });
      } else {
        setState((){
            _isLoading = false;
          });
        _showError("Login failed. Please check your credentials.");
      }
    } catch (e) {
      print("Login error: $e");
      _showError("Incorrect email or password. Please try again.");
    }
  }

  void _showChildSelectionDialog(List<QueryDocumentSnapshot> children) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select a Child",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 15),
            ListView.separated(
              separatorBuilder: (_, __) => const Divider(),
              shrinkWrap: true,
              itemCount: children.length,
              itemBuilder: (context, index) {
                var child = children[index].data() as Map<String, dynamic>;
                child['id'] = children[index].id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: const Icon(Icons.child_care, color: Colors.purple),
                  ),
                  title: Text(
                    child['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Birthdate: ${child['birthdate']}"),
                  onTap: () {
                    Navigator.pop(context); 
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainMenu(childData: child),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddChildPage()),
                  );
                  if (result == 'child_added') {
                    _logIn(); 
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Add Another Child", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
void _showForgotPasswordDialog() {
  final TextEditingController _forgotEmailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Reset Password"),
      content: TextField(
        controller: _forgotEmailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: "Enter your registered email",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
          child: const Text("Send Reset Link"),
          onPressed: () async {
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: _forgotEmailController.text.trim(),
              );
              Navigator.pop(context);
              _showError("Reset link sent to your email.");
            } catch (e) {
              Navigator.pop(context);
              _showError("Error sending reset email. Check email address.");
            }
          },
        ),
      ],
    ),
  );
}




  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  }

  Route _createRoute(Widget page) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
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

