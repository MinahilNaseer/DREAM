import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class DysgraphiaScreen extends StatefulWidget {
  @override
  _DysgraphiaScreenState createState() => _DysgraphiaScreenState();
}

class _DysgraphiaScreenState extends State<DysgraphiaScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  bool _showAnalyzeButton = false;
  String? _result;
  String? _selectedWord;
  int _uploadCount = 0; // Counter to track number of uploads

  final String backendUrl = 'http://192.168.18.84:5000/analyze-handwriting';

  // List of recommended words for dysgraphia detection
  final List<String> words = [
    "dog", "bed", "happy", "jump", "moon",
    "tree", "apple", "sun", "fish", "was", "and","play"
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null;
        _showAnalyzeButton = true;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null || _selectedWord == null) return;

    setState(() {
      _isUploading = true;
      _showAnalyzeButton = false;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
      request.fields['word'] = _selectedWord!;

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          _result = responseBody;
          _uploadCount++; // Increment counter after successful upload
          _selectedImage = null; // Reset selected image after upload
          _selectedWord = null; // Reset selected word after upload
        });
      } else {
        setState(() {
          _result = 'Error: Unable to process the image';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dysgraphia Detection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Counter at the top
            Text(
              '$_uploadCount / 5', // Display upload progress
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            SizedBox(height: 10),

            // Word Selection
            Text("Select a Word to Write:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: words.map((word) {
                return ChoiceChip(
                  label: Text(word, style: TextStyle(fontSize: 16, color: Colors.black)),
                  selected: _selectedWord == word,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedWord = selected ? word : null;
                    });
                  },
                  selectedColor: Colors.blueAccent,
                  labelStyle: TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Centered "No image selected" message
            if (_selectedImage == null)
              Text(
                'No image selected. Please upload a handwriting sample.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            
            if (_selectedImage != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 16),
                  if (_showAnalyzeButton)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isUploading ? null : _uploadImage,
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Upload & Analyze', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                ],
              ),
            
            // Buttons at the bottom of the screen
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt , color: Colors.white,),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 26, 149, 186),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _pickImage(ImageSource.camera),
                  label: Text('Camera', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library, color: Colors.white,),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color.fromARGB(255, 26, 149, 186),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  label: Text('Gallery', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Result Display
            if (_result != null)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Result: $_result',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
