import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:dream/screens/screenclass/cardoption.dart' as cardoption;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:dream/screens/dyscalculia_report.dart";
import 'package:cloud_firestore/cloud_firestore.dart';


class DyscalculiaLevel extends StatefulWidget {
  final Map<String, dynamic> childData;
   const DyscalculiaLevel({Key? key, required this.childData}) : super(key: key);
  @override
  _DyscalculiaLevelState createState() => _DyscalculiaLevelState();
}

class _DyscalculiaLevelState extends State<DyscalculiaLevel> {
  int currentQuestionIndex = 0;
  int totalQuestions = 10;

  bool showIntroScreen = true;
  String? selectedOption;
  Color selectedColor = Colors.transparent;

  List<Widget> questions = [];
  List<String> correctAnswers = [];
  List<String> questionsText = []; 
  List<List<String>> options = [];
  int totalCorrectAnswers = 0;
  int totalTimeTaken = 0;
  DateTime? startTime;
  DateTime? questionStartTime;

  final FlutterTts flutterTts = FlutterTts();
  bool isReadyScreen = true;
  bool isCountingDown = false;
  int countdown = 3;

  String? selectedChildId;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _generateQuestions(); 
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

  void _startCountdown() {
    setState(() {
      isCountingDown = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => countdown = 2);
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => countdown = 1);
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isReadyScreen = false;
        isCountingDown = false;
        showIntroScreen = false;
        _startQuizTimer();
        _startQuestionTimer();
        _speakQuestion();
      });
    });
  }


  void _startQuestionTimer() {
    questionStartTime = DateTime.now(); 
  }

  void _startQuizTimer() {
  startTime = DateTime.now(); 
}


  void _generateQuestions() {
  Random random = Random();
  questions.clear();
  correctAnswers.clear();
  questionsText.clear();
  options.clear();

  
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
      "questionText": "9 - 6",
      "correctAnswer": "3",
      "options": ["9", "3", "6", "4"]
    },
    {
      "questionText": "9 + 6",
      "correctAnswer": "15",
      "options": ["15", "12", "14", "13"]
    },
  ];

  
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

      
      Set<String> generatedOptions = {correctAnswer};
      while (generatedOptions.length < 4) {
        generatedOptions.add((random.nextInt(9)).toString());
      }
      options.add(generatedOptions.toList()..shuffle());
    }
  }

  
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
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
        const Text(
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
      _startQuestionTimer(); 
      _speakQuestion();
    } else {
      totalTimeTaken = startTime != null
          ? DateTime.now().difference(startTime!).inSeconds
          : 0;
      _showResults();
    }
    selectedOption = null;
    selectedColor = Colors.transparent;
  });
}

  Future<void> _checkAnswer(String answer) async {
  double responseTime = DateTime.now().difference(questionStartTime!).inSeconds.toDouble();

  
  Map<String, double> questionFlags = {
    'Question_"6 + 3"': 0.0,
    'Question_"7 + 2"': 0.0,
    'Question_"9 + 6"': 0.0,
    'Question_"9 - 6"': 0.0,
  };
  String currentQuestionText = questionsText[currentQuestionIndex];
  questionFlags['Question_"$currentQuestionText"'] = 1.0;

  
  Map<String, dynamic> dataPayload = {
    "Correct_Answer": double.parse(correctAnswers[currentQuestionIndex]),
    "Selected_Option": double.parse(answer),
    "Response_Time": responseTime,
    "Question_Type": 1.0, 
    "Is_Hardcoded": 1.0,  
    ...questionFlags,
  };

  
  await sendDataToBackend(dataPayload);

  
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

Future<void> sendDataToBackend(Map<String, dynamic> dataPayload) async {
  try {
    
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user?.uid ?? 'no_uid_found';

    
    QuerySnapshot childrenSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('children')
        .get();

    if (childrenSnapshot.docs.isEmpty) {
      print("No children found for this user.");
      return;
    }

    final String urlString =
        dotenv.env['BACKEND_URL_DYSCAL'] ?? 'DEFAULT_FALLBACK_URL';
    final Uri url = Uri.parse(urlString);

    
    for (var childDoc in childrenSnapshot.docs) {
            selectedChildId = childDoc.id;

      print("Sending data for childId: $selectedChildId");
      print("Data: ${dataPayload.values.toList()}");
      print("URL: $url");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "uid": uid,
          "childId": selectedChildId,
          "features": dataPayload.values.toList(),
        }),
      );

      if (response.statusCode == 200) {
        final prediction = jsonDecode(response.body)['prediction'];
        print(prediction == 1
            ? "The child ($selectedChildId) may have dyscalculia."
            : "The child ($selectedChildId) does not show signs of dyscalculia.");
      } else {
        print("Failed for child ($selectedChildId). Status: ${response.statusCode}");
      }
    }
  } catch (e) {
    print("Error sending data to backend: $e");
  }
}


  void _showResults() {
    totalTimeTaken = startTime != null
      ? DateTime.now().difference(startTime!).inSeconds
      : 0;

  
  int minutes = totalTimeTaken ~/ 60; 
  int seconds = totalTimeTaken % 60; 

  String timeDisplay = minutes > 0
      ? "$minutes minute${minutes > 1 ? 's' : ''} and $seconds second${seconds > 1 ? 's' : ''}"
      : "$seconds second${seconds > 1 ? 's' : ''}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Correct Answers: $totalCorrectAnswers\n'
                'Time Taken: $timeDisplay\n'
                'Thank you for participating!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
  context,
  '/dyscalculia_report'
);
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Text(
        'Generate Report',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 122, 27, 151),
        ),
      ),
      SizedBox(width: 10),
      Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
    ],
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

  void _onContinue() async {
    bool isLoading = false;

  if (selectedOption != null) {
    setState(() {
      isLoading = true; 
    });

    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(), 
        );
      },
    );

    await _checkAnswer(selectedOption!); 

    Navigator.of(context).pop(); 
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false; 
        _nextQuestion(); 
      });
    });
  }
}


  @override
  Widget build(BuildContext context) {
    if (showIntroScreen) {
      return Scaffold(
        body: Center(
          child: isCountingDown
              ? Text(
                  countdown.toString(),
                  style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.purple),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Are you ready to test your child?",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _startCountdown,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text("Start", style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  ],
                ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dyscalculia Detection (${currentQuestionIndex + 1}/$totalQuestions)',
          style: const TextStyle(color: Colors.white),
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
              gridDelegate: const  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 2.5,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4, 
              itemBuilder: (context, index) {
                String option = options[currentQuestionIndex][index];
                return cardoption.CardOption(
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


