import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;

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
  int _uploadCount = 0;

  final String backendUrl =
      dotenv.env['BACKEND_URL_DYSG'] ?? 'DEFAULT_FALLBACK_URL';

  final List<String> words = [
    "dog",
    "bed",
    "happy",
    "jump",
    "moon",
    "mist",
    "tree",
    "apple",
    "sun",
    "fish",
    "was",
    "and",
    "play",
    "drag",
    "pet",
    "fan",
    "jeep",
    "bead",
    "snap"
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Fix image rotation
      imageFile = await _fixImageRotation(imageFile);

      setState(() {
        _selectedImage = imageFile;
        _result = null;
        _showAnalyzeButton = true;
      });
    }
  }

  Future<File> _fixImageRotation(File imageFile) async {
    final imageBytes = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      return imageFile; // Return original file if decoding fails
    }

    // Auto-fix orientation
    final orientedImage = img.bakeOrientation(decodedImage);

    // Save fixed image
    final fixedFile = File(imageFile.path)
      ..writeAsBytesSync(img.encodeJpg(orientedImage));
    return fixedFile;
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null || _selectedWord == null) return;

    setState(() {
      _isUploading = true; // Show loader
      _result = null; // Hide previous results
      _showAnalyzeButton = false;
    });

    try {
      File resizedImage = await _resizeImage(_selectedImage!);

      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files
          .add(await http.MultipartFile.fromPath('image', resizedImage.path));
      request.fields['word'] = _selectedWord!;

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          _result = responseBody;
          _uploadCount++;
          _selectedImage = null;
          _selectedWord = null;
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
        _isUploading = false; // Hide loader after uploading
      });
    }
  }

  Future<File> _resizeImage(File imageFile) async {
    final imageBytes = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      return imageFile; // Return original file if decoding fails
    }

    final resizedImage = img.copyResize(decodedImage, width: 128, height: 128);
    final resizedFile = File(imageFile.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage));

    return resizedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dysgraphia Detection',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              '$_uploadCount / 5',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54),
            ),
            SizedBox(height: 10),
            Text("Select a Word to Write:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: words.map((word) {
                return ChoiceChip(
                  label: Text(word,
                      style: TextStyle(fontSize: 16, color: Colors.black)),
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
                    child: Image.file(_selectedImage!,
                        height: 200, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 16),
                  if (_showAnalyzeButton)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isUploading ? null : _uploadImage,
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Upload & Analyze',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                ],
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 26, 149, 186),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _pickImage(ImageSource.camera),
                  label: Text('Camera',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.photo_library,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 26, 149, 186),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  label: Text('Gallery',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_isUploading)
              Column(
                children: [
                  CircularProgressIndicator(
                      color: Colors.blueAccent), // Show Loader
                  SizedBox(height: 16),
                  Text(
                    'Analyzing Handwriting...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else if (_result != null)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Result: $_result',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
