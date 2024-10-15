import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help',
          style: TextStyle(color: Colors.white), // Change font color to white
        ),
         backgroundColor: Colors.purple, 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
              _buildFAQItem(
                context,
                question: 'How do I reset my password?',
                answer:
                    'To reset your password, go to the login page and click on "Forgot Password?" Follow the instructions sent to your email.',
              ),
              _buildFAQItem(
                context,
                question: 'How can I contact support?',
                answer:
                    'You can contact our support team through the contact form available in the app or email us at support@example.com.',
              ),
              _buildFAQItem(
                context,
                question: 'Where can I find my reports?',
                answer:
                    'Your reports can be found in the "Reports / Results" section of your profile page.',
              ),
              _buildFAQItem(
                context,
                question: 'How do I update my personal information?',
                answer:
                    'To update your personal information, go to the "Edit Personal Information" section in your profile page.',
              ),
              _buildFAQItem(
                context,
                question: 'How can I log out?',
                answer:
                    'You can log out from your profile page by clicking on the "Logout" button.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context,
      {required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
