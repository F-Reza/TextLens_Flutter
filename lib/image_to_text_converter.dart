import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class ImageToTextConverter extends StatefulWidget {
  const ImageToTextConverter({super.key});

  @override
  _ImageToTextConverterState createState() => _ImageToTextConverterState();
}

class _ImageToTextConverterState extends State<ImageToTextConverter> {
  File? _selectedImage;
  String _extractedText = "";
  bool _isProcessing = false;

  final ImagePicker _imagePicker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _extractedText = "";
      });
      _processImage();
    }
  }

  // Function to capture an image using the camera
  Future<void> _captureImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _extractedText = "";
      });
      _processImage();
    }
  }

  // Function to process the selected or captured image
  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();

      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
      });

      await textRecognizer.close();
    } catch (e) {
      setState(() {
        _extractedText = "Error: $e";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image to Text Converter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display selected image or a placeholder
            _selectedImage == null
                ? Placeholder(
              fallbackHeight: 200,
            )
                : Image.file(
              _selectedImage!,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            // Buttons for selecting or capturing an image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text("Pick Image"),
                ),
                ElevatedButton.icon(
                  onPressed: _captureImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text("Capture Image"),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Show a loading indicator while processing
            _isProcessing
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _extractedText.isEmpty
                      ? "Extracted text will appear here."
                      : _extractedText,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
