import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer';
import 'package:flutter_gemini/flutter_gemini.dart';

class CropScanPage extends StatefulWidget {
  const CropScanPage({super.key});

  @override
  _CropScanPageState createState() => _CropScanPageState();
}

class _CropScanPageState extends State<CropScanPage> {
  File? _image;
  bool _loading = false;
  String? _analysisResult;

  final Gemini gemini = Gemini.instance; // Create an instance of Gemini

  @override
  void initState() {
    super.initState();
  }

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _loading = true;
        _analysisResult = null; // Clear previous results
      });
      await analyzeImage(_image!);
    }
  }

  // Analyze image using Gemini's textAndImage function
  Future<void> analyzeImage(File image) async {
    try {
      // Read image as bytes for the Gemini API
      final imageBytes = image.readAsBytesSync();

      // Call Gemini API with the prompt and image
      final response = await gemini.textAndImage(
        modelName: "models/gemini-1.5-flash",
text: "Identify any disease present in this plant image and provide respective precautions. If no disease is detected or the plant appears healthy, please confirm it as healthy.", 
        images: [imageBytes], // Pass image as bytes
      );

      setState(() {
        _analysisResult = response?.content?.parts?.last.text ?? 'No analysis result found.';
        _loading = false;
      });
    } catch (e) {
      log("Error during image analysis", error: e);
      setState(() {
        _loading = false;
        _analysisResult = "Failed to analyze the image. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Scan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: _image == null
                    ? Center(child: Text("Tap to pick an image"))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : _analysisResult != null
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _analysisResult!,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    : Text("No results to show."),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}