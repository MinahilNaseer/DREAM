import 'dart:math';
import 'package:flutter/material.dart';

class DyscalculiaLevel extends StatefulWidget {
  @override
  _DyscalculiaLevelState createState() => _DyscalculiaLevelState();
}

class _DyscalculiaLevelState extends State<DyscalculiaLevel> {
  int currentQuestionIndex = 0;
  String? selectedOption;
  Color selectedColor = Colors.transparent;

  // List to hold randomly generated questions and their correct answers
  List<String> questions = [];
  List<String> correctAnswers = [];
  int totalCorrectAnswers = 0;
  int totalTimeTaken = 0;
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    _generateQuestions(); // Generate questions on initialization
    startTime = DateTime.now(); // Start timing
  }

  void _generateQuestions() {
    Random random = Random();
    while (questions.length < 10) { // Ensure exactly 10 questions are generated
      int num1 = random.nextInt(10); // Random number between 0 and 9
      int num2 = random.nextInt(10); // Random number between 0 and 9

      // Randomly decide whether to generate an addition or subtraction question
      bool isAddition = random.nextBool();

      // Generate question based on the operation
      if (isAddition) {
        if (num1 + num2 > 9 || num1 + num2 <= 0) {
          continue; // Skip if sum is greater than 9 or less than or equal to 0
        }
        questions.add("$num1 + $num2 =");
        correctAnswers.add((num1 + num2).toString()); // Calculate correct answer for addition
      } else {
        // For subtraction, ensure that num1 is greater than num2 to avoid negative results
        if (num1 < num2) {
          continue; // Skip if the first number is less than the second
        }
        questions.add("$num1 - $num2 =");
        correctAnswers.add((num1 - num2).toString()); // Calculate correct answer for subtraction
      }
    }
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        totalTimeTaken = DateTime.now().difference(startTime!).inSeconds; // Calculate total time taken
        _showResults(); // Show results when all questions are answered
        return; // Exit the function to avoid resetting the index prematurely
      }
      selectedOption = null; // Reset selected option for the next question
      selectedColor = Colors.transparent; // Reset color
    });
  }

  Future<void> _checkAnswer(String answer) async {
    if (answer == correctAnswers[currentQuestionIndex]) {
      setState(() {
        selectedColor = Colors.green; // Set color to green for correct answer
        totalCorrectAnswers++; // Increment total correct answers
      });
    } else {
      setState(() {
        selectedColor = Colors.red; // Set color to red for incorrect answer
      });
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Correct Answers: $totalCorrectAnswers\n'
                'Time Taken: $totalTimeTaken seconds\n'
                'Thank you for participating!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20), // Space between text and button
              ElevatedButton(
                onPressed: () {
                  _generateReport();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Generate Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10), // Space between text and icon
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Purple background
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Navigate to /mainmenu when the dialog is dismissed
      Navigator.of(context).pushReplacementNamed('/mainmenu');
    });
  }

  // Placeholder function for generating a report
  void _generateReport() {
    // Implement your report generation logic here
    print('Report generated!'); // Replace with actual report logic
  }

  void _onContinue() {
    if (selectedOption != null) {
      _checkAnswer(selectedOption!);

      // Show the selected color for 1 second before moving to the next question
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
                    itemCount: 4, // Number of options
                    itemBuilder: (context, index) {
                      String option = (int.parse(correctAnswers[currentQuestionIndex]) + (index - 2)).toString();
                      return CardOption(
                        text: option,
                        isSelected: selectedOption == option,
                        selectedColor: selectedColor,
                        onTap: () {
                          setState(() {
                            selectedOption = option;
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

  const CardOption({
    required this.text,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: isSelected ? selectedColor : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        color: isSelected ? selectedColor : Colors.white,
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
