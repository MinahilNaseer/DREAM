import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';

class DyscalculiaLevel extends StatefulWidget {
  @override
  _DyscalculiaLevelState createState() => _DyscalculiaLevelState();
}

class _DyscalculiaLevelState extends State<DyscalculiaLevel> {
  int currentQuestionIndex = 0;
  String? selectedOption;
  Color selectedColor = Colors.transparent;

  List<Widget> questions = [];
  List<String> correctAnswers = [];
  List<String> questionsText = []; 
  List<List<String>> options = [];
  int totalCorrectAnswers = 0;
  int totalTimeTaken = 0;
  DateTime? startTime;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _generateQuestions(); 
    startTime = DateTime.now(); 
    _speakQuestion();
  }

  void _initializeTts() async {
    try {
      await flutterTts.setLanguage("en-US"); 
      await flutterTts.setSpeechRate(0.5);   
      await flutterTts.setPitch(1.0);        
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  void _generateQuestions() {
  Random random = Random();
  questions.clear();
  correctAnswers.clear();
  questionsText.clear();
  options.clear();

  // Hard-coded specific single-digit questions
  List<Map<String, dynamic>> specificQuestions = [
    {
      "questionText": "6 + 3",
      "correctAnswer": "9",
      "options": ["6", "8", "9", "7"]
    },
    {
      "questionText": "9 - 6",
      "correctAnswer": "3",
      "options": ["9", "3", "6", "4"]
    },
    {
      "questionText": "7 + 2",
      "correctAnswer": "9",
      "options": ["9", "7", "8", "10"]
    },
    {
      "questionText": "8 - 3",
      "correctAnswer": "5",
      "options": ["6", "3", "7", "5"]
    },
    {
      "questionText": "9 + 6",
      "correctAnswer": "15",
      "options": ["15", "12", "14", "13"]
    },
  ];

  // Add hard-coded specific questions
  for (var sq in specificQuestions) {
    questionsText.add(sq["questionText"]);
    correctAnswers.add(sq["correctAnswer"]);
    questions.add(_buildTextQuestion(
      int.parse(sq["questionText"].split(" ")[0]),
      int.parse(sq["questionText"].split(" ")[2]),
      sq["questionText"].contains("+"),
    ));
    options.add(sq["options"]..shuffle());
  }

  // Add randomly generated questions
  while (questions.length < 10) {
    bool isImageQuestion = random.nextBool();

    if (isImageQuestion && questions.length < 7) {
      int num1 = random.nextInt(5) + 1;
      int num2 = random.nextInt(5) + 1;
      bool isAddition = random.nextBool();
      String correctAnswer;
      String questionText;

      if (isAddition) {
        correctAnswer = (num1 + num2).toString();
        questionText = "$num1 + $num2";
        questions.add(_buildImageQuestion(num1, num2, true));
      } else {
        if (num1 < num2) continue;
        correctAnswer = (num1 - num2).toString();
        questionText = "$num1 - $num2";
        questions.add(_buildImageQuestion(num1, num2, false));
      }

      correctAnswers.add(correctAnswer);
      questionsText.add(questionText);

      // Generate 4 unique options including the correct answer
      Set<String> generatedOptions = {correctAnswer};
      while (generatedOptions.length < 4) {
        generatedOptions.add((random.nextInt(9) + 1).toString());
      }
      options.add(generatedOptions.toList()..shuffle());
    } else if (!isImageQuestion && questions.length < 10) {
      int num1 = random.nextInt(10);
      int num2 = random.nextInt(10);
      bool isAddition = random.nextBool();
      String correctAnswer;
      String questionText;

      if (isAddition) {
        correctAnswer = (num1 + num2).toString();
        questionText = "$num1 + $num2";
        questions.add(_buildTextQuestion(num1, num2, true));
      } else {
        if (num1 < num2) continue;
        correctAnswer = (num1 - num2).toString();
        questionText = "$num1 - $num2";
        questions.add(_buildTextQuestion(num1, num2, false));
      }

      correctAnswers.add(correctAnswer);
      questionsText.add(questionText);

      // Generate 4 unique options including the correct answer
      Set<String> generatedOptions = {correctAnswer};
      while (generatedOptions.length < 4) {
        generatedOptions.add((random.nextInt(9)).toString());
      }
      options.add(generatedOptions.toList()..shuffle());
    }
  }

  // Shuffle questions to randomize the appearance of hard-coded and random questions
  List<int> indices = List<int>.generate(questions.length, (i) => i);
  indices.shuffle();
  questions = indices.map((i) => questions[i]).toList();
  correctAnswers = indices.map((i) => correctAnswers[i]).toList();
  questionsText = indices.map((i) => questionsText[i]).toList();
  options = indices.map((i) => options[i]).toList();
}



  Future<void> _speakQuestion() async {
    String questionText = questionsText[currentQuestionIndex];
    String ttsText = questionText
        .replaceAll("+", "plus")
        .replaceAll("-", "minus") +
        " equals what?";

    await flutterTts.speak(ttsText);
  }

  Widget _buildImageQuestion(int num1, int num2, bool isAddition) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10.0,
          children: List.generate(
            num1,
            (index) => Image.asset(
              'assets/images/ball.png', 
              width: 50,
              height: 50,
            ),
          ),
        ),
        Text(
          isAddition ? "+" : "-",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10.0,
          children: List.generate(
            num2,
            (index) => Image.asset(
              'assets/images/ball.png', 
              width: 50,
              height: 50,
            ),
          ),
        ),
        Text(
          "= ?",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextQuestion(int num1, int num2, bool isAddition) {
    return Text(
      "$num1 ${isAddition ? "+" : "-"} $num2 = ?",
      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
    );
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        _speakQuestion(); 
      } else {
        totalTimeTaken = DateTime.now().difference(startTime!).inSeconds;
        _showResults();
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
    int minutes = totalTimeTaken ~/ 60; 
    int seconds = totalTimeTaken % 60; 

    String timeDisplay;
    if (minutes > 0) {
      timeDisplay = "$minutes minute${minutes > 1 ? 's' : ''} and $seconds second${seconds > 1 ? 's' : ''}";
    } else {
      timeDisplay = "$seconds second${seconds > 1 ? 's' : ''}";
    }

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
                'Time Taken: $timeDisplay\n'
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
          'Dyscalculia Detection',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 250, 
              alignment: Alignment.center,
              child: questions[currentQuestionIndex],
            ),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 2.5,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 4, 
              itemBuilder: (context, index) {
                String option = options[currentQuestionIndex][index];
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
                disabledBackgroundColor: Colors.grey,
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
