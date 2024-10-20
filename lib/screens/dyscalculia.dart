import 'package:flutter/material.dart';

class DyscalculiaLevel extends StatefulWidget {
  @override
  _DyscalculiaLevelState createState() => _DyscalculiaLevelState();
}

class _DyscalculiaLevelState extends State<DyscalculiaLevel> {
  int currentQuestionIndex = 0;
  String? selectedOption;
  Color selectedColor = Colors.transparent;

  // Basic addition and subtraction questions
  List<String> questions = [
    "3 + 2 =",
    "5 - 1 =",
    "4 + 6 =",
    "10 - 7 =",
    "8 + 1 =",
  ];

  List<List<String>> options = [
    ["4", "5", "6", "2"],
    ["4", "3", "5", "2"],
    ["9", "10", "8", "6"],
    ["3", "2", "4", "6"],
    ["9", "10", "7", "6"],
  ];

  List<String> correctAnswers = ["5", "4", "10", "3", "9"]; // Correct answers

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        currentQuestionIndex = 0; // Reset or navigate to the next level/screen
      }
      selectedOption = null; // Reset selected option for the next question
      selectedColor = Colors.transparent; // Reset color
    });
  }

  Future<void> _checkAnswer(String answer) async {
    if (answer == correctAnswers[currentQuestionIndex]) {
      setState(() {
        selectedColor = Colors.green; // Set color to green for correct answer
      });
    } else {
      setState(() {
        selectedColor = Colors.red; // Set color to red for incorrect answer
      });
    }
  }

  void _onContinue() {
    if (selectedOption != null) {
      // Check answer before moving on
      _checkAnswer(selectedOption!);

      // Show the selected color for 3 seconds
      Future.delayed(Duration(seconds: 1), () {
        _nextQuestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dyscalculia Detection Level',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100), // Add space at the top
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  questions[currentQuestionIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10), // Space between '=' and the box
                Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
            SizedBox(height: 150), // Space between question and options
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two options per row
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: options[currentQuestionIndex].length,
                    itemBuilder: (context, index) {
                      return CardOption(
                        text: options[currentQuestionIndex][index],
                        isSelected: selectedOption == options[currentQuestionIndex][index],
                        selectedColor: selectedColor,
                        onTap: () {
                          setState(() {
                            selectedOption = options[currentQuestionIndex][index];
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 50), // Space between options and button
                  ElevatedButton(
                    onPressed: selectedOption != null ? _onContinue : null, // Disable if no option selected
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 236, 230, 230),
                          ),
                        ),
                        SizedBox(width: 10), // Space between text and icon
                        Icon(
                          Icons.arrow_forward,
                          color: const Color.fromARGB(255, 236, 230, 230),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      disabledBackgroundColor: Colors.grey, // Change color when disabled
                    ),
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
  final bool isSelected;
  final Color selectedColor; // Accept the selected color
  final VoidCallback onTap;

  const CardOption({required this.text, required this.isSelected, required this.selectedColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.purple, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : const Color.fromARGB(255, 210, 170, 218),
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
