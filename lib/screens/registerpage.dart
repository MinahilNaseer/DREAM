import '../../u_auth/firebase_auth/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController relationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  String? selectedGender; // Variable to store selected gender


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfffeeed7), // Transparent background for the AppBar
        elevation: 0, // Remove the shadow under the AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple, size: 30,), // Back icon
          onPressed: () {
            Navigator.pop(context); // Use pop to go back to the previous page
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background-reg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form( // Wrap the form with a Form widget
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "Register",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.purple),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name of Child',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the name of the child';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: birthdateController,
                          decoration: InputDecoration(
                            labelText: 'Birthdate',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the birthdate';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: relationController,
                          decoration: InputDecoration(
                            labelText: 'Relation (e.g., Parent, Guardian)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: const Icon(Icons.family_restroom),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your relation';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a gender';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!RegExp(
                                    r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password (********)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: const Icon(Icons.visibility),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            } else if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
                              return 'Password must contain at least one capital letter';
                            } else if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
                              return 'Password must contain at least one number';
                            } else if (!RegExp(r'(?=.*?[!@#\$&*~])').hasMatch(value)) {
                              return 'Password must contain at least one symbol';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async{
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a message
                                  _signUp();
                                }
                              },
                              child: const Text(
                                'REGISTER',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    birthdateController.dispose();
    relationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  void _signUp() async{
    String name = nameController.text;
    String birthdate = birthdateController.text;
    String relation = relationController.text;
    String email = emailController.text;
    String password = passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    if(user!=null)
    {
      print("User succesfully Registered");
      Navigator.pushNamed(context, "/login"); 
    }
    else{
      print("Some error occured");
    }
  }
}
