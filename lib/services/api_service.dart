import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int> predictDyscalculia(List<double> features) async {
  final url = Uri.parse('http://127.0.0.1:5000/predict');
  
  // Send POST request with feature data
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'features': features}),
  );

  if (response.statusCode == 200) {
    // Parse the prediction
    final data = jsonDecode(response.body);
    return data['prediction']; // 0 or 1
  } else {
    throw Exception('Failed to get prediction');
  }
}
