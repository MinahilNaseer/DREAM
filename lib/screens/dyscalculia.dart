import 'package:flutter/material.dart';

class DyscalculiaLevel extends StatefulWidget {
  @override
  _DyscalculiaLevelState createState() => _DyscalculiaLevelState();
}

class _DyscalculiaLevelState extends State<DyscalculiaLevel> {
  int currentQuestionIndex = 0;

  // Basic addition and subtraction questions
  List<String> questions = [
    "3 + 2 =",
    "5 - 1 =",
    "4 + 6 =",
    "10 - 7 =",
    "8 + 1 =",
  ];

  List<List<String>> options = [
    ["4", "5", "6","2"],
    ["4", "3", "5",'2'],
    ["9", "10", "8","6"],
    ["3", "2", "4","6"],
    ["9", "10", "7","6"],
  ];

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        currentQuestionIndex = 0; // Reset or navigate to the next level/screen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dyscalculia Detection Level',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple, // Softer blue shade for header
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align to start
          children: [
            SizedBox(height: 100), // Add space at the top
            // Display question directly with an empty box after '='
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  questions[currentQuestionIndex],
                  textAlign: TextAlign.center, // Center align question text
                  style: TextStyle(
                    fontSize: 40, // Larger font size for visibility
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Dark color for better readability
                  ),
                ),
                SizedBox(width: 10), // Space between '=' and the box
                Container(
                  width: 50, // Width of the empty box
                  height: 40, // Height of the empty box
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple, width: 2), // Border for the box
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                ),
              ],
            ),
            SizedBox(height:150), // Space between question and options
            // Options section as cards
            Expanded( // Allow options to take the remaining space
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Align options to the start
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two options per row
                      childAspectRatio: 1.5, // Adjust aspect ratio for better layout
                      crossAxisSpacing: 20, // Spacing between columns
                      mainAxisSpacing: 20, // Spacing between rows
                    ),
                    shrinkWrap: true, // Prevent overflow
                    physics: NeverScrollableScrollPhysics(), // Disable scrolling
                    itemCount: options[currentQuestionIndex].length,
                    itemBuilder: (context, index) {
                      return CardOption(
                        text: options[currentQuestionIndex][index],
                        onTap: () {
                          _nextQuestion();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardOption extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CardOption({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.purple, width: 2), // Purple border
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 210, 170, 218), // Light background for contrast
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
