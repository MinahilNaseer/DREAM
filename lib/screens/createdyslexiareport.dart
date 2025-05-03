import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:dream/global.dart';

class DyslexiaReportService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> createAndSendPromptToBackend() async {
    final user = _auth.currentUser;
    if (user == null || currentSelectedChildId == null) return;

    final scores = await _getScores(user.uid, currentSelectedChildId!);
    if (scores == null) return;

    final result = _calculateDyslexiaRisk(scores);
    final promptData = {
      'uid': user.uid,
      'child_id': currentSelectedChildId!,
      'scores': {
        'fishingLevelScore': scores['fishingLevelScore'] ?? 0,
        'forestLevelScore': scores['forestLevelScore'] ?? 0,
        'colorLetterLevelScore': scores['colorLetterLevelScore'] ?? 0,
        'pronunciationLevelScore': scores['pronunciationLevelScore'] ?? 0,
        'total_score': result['totalScore'],
        'percentage': result['percentage'],
        'risk': result['risk'],
      }
    };

    // Fetch the URL from the .env file
    final String urlString = dotenv.env['BACKEND_URL_DYS'] ?? 'DEFAULT_FALLBACK_URL';
    final Uri url = Uri.parse(urlString);
 
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(promptData),
    );

    if (response.statusCode == 200) {
      print("✅ Report generated and saved successfully.");
    } else {
      print("❌ Failed to generate report: ${response.body}");
    }
  }

  Future<Map<String, dynamic>?> _getScores(String uid, String childId) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId)
        .collection('dyslexiascore')
        .doc('game_scores')
        .get();
    return doc.data();
  }

  Map<String, dynamic> _calculateDyslexiaRisk(Map<String, dynamic> scores) {
  // Ensure scores are safely cast to double, then to int
  int fishing = (scores['fishingLevelScore']?.toDouble() ?? 0.0).toInt();
  int audio = (scores['forestLevelScore']?.toDouble() ?? 0.0).toInt();
  int colorLetter = (scores['colorLetterLevelScore']?.toDouble() ?? 0.0).toInt();
  int reading = (scores['pronunciationLevelScore']?.toDouble() ?? 0.0).toInt();
  
  int totalScore = fishing + audio + colorLetter + reading;
  double percentage = (totalScore / 9) * 100;
  String risk;

  if (percentage <= 50) {
    risk = 'High Risk of Dyslexia';
  } else if (percentage <= 75) {
    risk = 'Moderate Risk of Dyslexia';
  } else {
    risk = 'Low Risk of Dyslexia';
  }

  return {
    'totalScore': totalScore,
    'percentage': percentage.toStringAsFixed(1),
    'risk': risk,
  };
}
}
