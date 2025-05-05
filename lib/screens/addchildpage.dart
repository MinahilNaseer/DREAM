import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:dream/screens/loginpage.dart';

class AddChildPage extends StatefulWidget {
  const AddChildPage({super.key});

  @override
  _AddChildPageState createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  String? selectedGender;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  Future<void> _addChild() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference childRef = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('children')
            .add({
          'name': nameController.text,
          'birthdate': birthdateController.text,
          'gender': selectedGender ?? 'Unknown',
          'createdAt': Timestamp.now(),
        });
        
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Child added successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      
      await Future.delayed(const Duration(seconds: 2));

        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add child: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  DateTime? selectedDate;

  Future<void> _pickBirthdate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 5, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        birthdateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  bool _validateChildAge() {
    if (selectedDate == null) return false;
    DateTime now = DateTime.now();
    Duration difference = now.difference(selectedDate!);
    int ageInYears = (difference.inDays / 365).floor();
    return ageInYears >= 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdeef4),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: const Text(
          'Add Child',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, 'cancelled'),

        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
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
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Child Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter child name'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: birthdateController,
                    readOnly: true,
                    onTap: _pickBirthdate,
                    decoration: InputDecoration(
                      labelText: 'Birthdate',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select birthdate';
                      }
                      if (!_validateChildAge()) {
                        return 'Child must be at least 5 years old';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedGender = value),
                    validator: (value) =>
                        value == null ? 'Please select a gender' : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 180,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Child",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: _addChild,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
