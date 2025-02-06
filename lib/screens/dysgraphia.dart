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

  final String backendUrl = 'http://your-backend-url/analyze-handwriting';

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null;
        _showAnalyzeButton = true; // Show analyze button after image selection
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _showAnalyzeButton = false; // Hide button while uploading
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          _result = responseBody;
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
                          : Text('Upload & Analyze', style: TextStyle(fontSize: 16)),
                    ),
                ],
              )
            else
              Text(
                'No image selected. Please upload a handwriting sample.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _pickImage(ImageSource.camera),
                  label: Text('Camera', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  label: Text('Gallery', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            SizedBox(height: 20),
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