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

  
  List<String> questions = [];
  List<String> correctAnswers = [];
  int totalCorrectAnswers = 0;
  int totalTimeTaken = 0;
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    _generateQuestions(); 
    startTime = DateTime.now(); 
  }

  void _generateQuestions() {
    Random random = Random();
    while (questions.length < 10) { 
      int num1 = random.nextInt(10); 
      int num2 = random.nextInt(10); 

      
      bool isAddition = random.nextBool();

      
      if (isAddition) {
        if (num1 + num2 > 9 || num1 + num2 <= 0) {
          continue; 
        }
        questions.add("$num1 + $num2 =");
        correctAnswers.add((num1 + num2).toString()); 
      } else {
        
        if (num1 < num2) {
          continue; 
        }
        questions.add("$num1 - $num2 =");
        correctAnswers.add((num1 - num2).toString()); 
      }
    }
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        totalTimeTaken = DateTime.now().difference(startTime!).inSeconds; 
        _showResults(); 
        return; 
      }
      selectedOption = null; 
      selectedColor = Colors.transparent; 
    });
  }

  Future<void> _checkAnswer(String answer) async {
    if (answer == correctAnswers[currentQuestionIndex]) {
      setState(() {
        selectedColor = Colors.green; 
        totalCorrectAnswers++; 
      });
    } else {
      setState(() {
        selectedColor = Colors.red; 
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
              SizedBox(height: 20), 
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
                    SizedBox(width: 10), 
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, 
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      
      Navigator.of(context).pushReplacementNamed('/mainmenu');
    });
  }

  
  void _generateReport() {
    
    print('Report generated!'); 
  }

  void _onContinue() {
    if (selectedOption != null) {
      _checkAnswer(selectedOption!);

      
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
            SizedBox(height: 100), 
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
                SizedBox(width: 10), 
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
            SizedBox(height: 150), 
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4, 
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
                  SizedBox(height: 50), 
                  ElevatedButton(
                    onPressed: selectedOption != null ? _onContinue : null, 
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
                        SizedBox(width: 10), 
                        Icon(
                          Icons.arrow_forward,
                          color: const Color.fromARGB(255, 236, 230, 230),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      disabledBackgroundColor: Colors.grey, 
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
  final Color selectedColor; 
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
