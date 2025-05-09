import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'package:dream/global.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DysgraphiaScreen extends StatefulWidget {
  final Map<String, dynamic> childData;
  const DysgraphiaScreen({super.key, required this.childData});

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

  final String backendUrl = dotenv.env['BACKEND_URL_DYSG'] ?? 'DEFAULT_FALLBACK_URL';

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
      return imageFile;
    }

    final orientedImage = img.bakeOrientation(decodedImage);

    final fixedFile = File(imageFile.path)
      ..writeAsBytesSync(img.encodeJpg(orientedImage));
    return fixedFile;
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null || _selectedWord == null) return;

    final user = FirebaseAuth.instance.currentUser;
    final childId = widget.childData['childId'];

    if (user == null || childId == null) {
      setState(() {
        _result = 'Missing user or child ID';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _result = null;
      _showAnalyzeButton = false;
    });

    try {
      File resizedImage = await _resizeImage(_selectedImage!);

      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('image', resizedImage.path));
      request.fields['word'] = _selectedWord!;
      request.fields['word'] = _selectedWord!;
      request.fields['uid'] = user.uid;
      request.fields['childId'] = childId;

      print("Sending to backend: UID=${user.uid}, ChildID=$childId");

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          _result = responseBody;
          _uploadCount++;
          _selectedImage = null;
          _selectedWord = null;

          if (_uploadCount >= 5) {
            _showCompletionDialog(); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("Upload successful. Select another word and image."),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
          }
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

  Future<File> _resizeImage(File imageFile) async {
    final imageBytes = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      return imageFile;
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(10),
              child: SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(words.length, (index) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 4 - 15,
                        child: ChoiceChip(
                          label: Text(
                            words[index],
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          selected: _selectedWord == words[index],
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedWord = selected ? words[index] : null;
                            });
                          },
                          selectedColor: Colors.blueAccent,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_selectedImage == null)
              Text(
                'No image uploaded. Please upload a handwriting sample.',
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
                  CircularProgressIndicator(color: Colors.blueAccent),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing Handwriting...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("All Completed!"),
          content: const Text("You've uploaded all 5 handwriting samples."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateReport();
              },
              child: const Text("Generate Report"),
            ),
          ],
        );
      },
    );
  }

  void _generateReport() async {
    await Future.delayed(Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Report generated. Navigate to profile to view the results."),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
